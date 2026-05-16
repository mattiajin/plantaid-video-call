#!/usr/bin/env python3
"""
Resolve Figma DTCG export (Mode N.tokens.json) to Swift Color constants.
Run: python3 figma_tokens_to_swift.py [path/to/Mode\\ 1.tokens.json] > TokenColors.generated.swift
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path


def components_to_hex(d: dict) -> str:
    comps = d.get("components") or []
    r, g, b = [int(round(float(x) * 255)) for x in comps[:3]]
    alpha = d.get("alpha")
    if alpha is not None:
        a = int(round(float(alpha) * 255))
        return f"#{r:02X}{g:02X}{b:02X}{a:02X}"
    return f"#{r:02X}{g:02X}{b:02X}"


def normalize_hex(h: str) -> str:
    h = h.strip().lstrip("#")
    if len(h) == 6:
        h = h + "FF"
    return h.upper()


def get_node(root: dict, path: list[str]):
    cur: object = root
    for part in path:
        if not isinstance(cur, dict) or part not in cur:
            return None
        cur = cur[part]
    return cur


def resolve_value(root: dict, val: object, stack: frozenset[str] | None = None) -> str | None:
    if stack is None:
        stack = frozenset()
    if isinstance(val, str):
        m = re.match(r"^\{([^}]+)\}$", val.strip())
        if m:
            path = m.group(1).split(".")
            key = ".".join(path)
            if key in stack:
                return None
            node = get_node(root, path)
            if isinstance(node, dict) and "$value" in node:
                return resolve_value(root, node["$value"], stack | {key})
            return None
        if val.startswith("#"):
            return normalize_hex(val)
        return None
    if isinstance(val, dict):
        if "hex" in val:
            return normalize_hex(val["hex"])
        if "components" in val:
            return components_to_hex(val)
    return None


def walk_semantic_color(
    obj: dict, root: dict, prefix: list[str], out: dict[str, str]
):
    for k, v in obj.items():
        if k.startswith("$"):
            continue
        path = prefix + [k]
        if isinstance(v, dict):
            if v.get("$type") == "color" and "$value" in v:
                hexv = resolve_value(root, v["$value"])
                if hexv:
                    name = ".".join(path)
                    out[name] = hexv
            else:
                walk_semantic_color(v, root, path, out)


def swift_hex_u32(hex8: str) -> str:
    """Emit 0xRRGGBB for Swift `Color(hex:)` (alpha separate)."""
    h = hex8.strip().lstrip("#")
    if len(h) == 8:
        h = h[:6]
    elif len(h) != 6:
        raise ValueError(hex8)
    return f"0x{h.upper()}"


# Maps existing DesignTokens names -> semantic path in JSON (Color.*)
SEMANTIC_MAP = {
    "background2": "Color.Background.2.Default",
    "background3": "Color.Background.3.Default",
    "background4": "Color.Background.4.Default",
    "background5": "Color.Background.5.Default",
    "background6": "Color.Background.6.Default",
    "foregroundHighlight": "Color.Foreground.Highlight.Default",
    "textHighlight": "Color.Text.Highlight.Default",
    "basicPrimary": "Color.Keys.Brand.90",  # B8FA64 常用作 Basic/Primary
    "foregroundDND": "Color.Foreground.DND.Default",
    "keysPurple60": "Color.Keys.Purple.60",
    "keysBrand50": "Color.Keys.Brand.50",
    "keysBrand20": "Color.Keys.Brand.20",
    "keysBrand90": "Color.Keys.Brand.90",
    "textWhiteImportant": "Color.Text.White.Important",
    "textWhitePrimary": "Color.Text.White.Primary",
    "textWhiteSecondary": "Color.Text.White.Secondary",
    "textWhiteTertiary": "Color.Text.White.Tertiary",
    "textWhiteDisable": "Color.Text.White.Disable",
    "textBlackPrimary": "Color.Text.Black.Primary",
    "textBlackOnColorPrimary": "Color.Text.Black On Color.Primary",
    "outline2": "Color.Outline.2.Default",
    "foregroundConsequential": "Color.Foreground.Consequentail.Default",
    "keysNeutralBlack": "Color.Keys.Neutral.Black",
    "keysNeutral5": "Color.Keys.Neutral.5",
    "chatFrameStroke": "Color.Foreground.DND.Default",
    # IM Lobby 麦克风环 Dev 常用 #63C0E8；变量表最近似为 Blue.80 (#5894D1) / Blue.100 (#67B3FF)。保留 DS token：
    "pushToTalkBorder": "Color.Keys.Blue.100",
    "pushToTalkFillBase": "Color.Keys.Neutral.10",
}


def main():
    default = Path(__file__).resolve().parents[1] / "xcode_test/BuzLobby/Tokens/Mode 1.tokens.json"
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else default
    data = json.loads(path.read_text(encoding="utf-8"))
    root = {"Color": data["Color"], "Number": data.get("Number", {})}

    all_colors: dict[str, str] = {}
    walk_semantic_color(data["Color"], root, ["Color"], all_colors)

    # push-to-talk cyan #63C0E8 — check Keys.Blue
    # Prefer exact semantic if present
    for candidate in (
        "Color.Keys.Blue.100",
        "Color.Foreground.DND.Default",
    ):
        if candidate in all_colors:
            pass

    lines: list[str] = [
        "//",
        "// 由 `scripts/figma_tokens_to_swift.py` 从 Figma Variables 导出生成，请勿手改。",
        f"// 源文件: {path.name}",
        "// 重新生成: `python3 scripts/figma_tokens_to_swift.py`",
        "//",
        "",
        "import SwiftUI",
        "",
        "/// 与 Figma `Color.*` 变量路径一一对应（Mode 1）。",
        "enum TokenColors {",
    ]

    for swift_name, semantic in SEMANTIC_MAP.items():
        hexv = all_colors.get(semantic)
        if not hexv:
            print(f"// WARN: missing {semantic}", file=sys.stderr)
            continue
        u32 = swift_hex_u32(hexv)
        lines.append(f"    /// `{semantic}` → #{hexv[:6]}")
        lines.append(f"    static let {swift_name} = Color(hex: {u32})")
        lines.append("")

    lines.append("}")
    lines.append("")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
