#!/usr/bin/env bash
set -e          # Stop on first error.

C_CYAN=$'\033[36m'
C_YELLOW=$'\033[33m'
C_GRAY=$'\033[37m'
C_GREEN=$'\033[32m'
C_NC=$'\033[0m' # Reset color | No color.

prompt_msg="Do you want to run 📦${C_YELLOW}sudo pacman -Syu --noconfirm${C_NC} first?"$'\n'
prompt_msg+="${C_CYAN}Confirm to run pacman update [y|yes|s|sim]:${C_NC} "
read -rp "$prompt_msg" confirm

confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

if [[ "$confirm" =~ ^(y|yes|s|sim)$ ]]; then
    echo "${C_YELLOW}📦 Updating system...${C_NC}"
    sudo pacman -Syu --noconfirm
else
    echo "${C_GRAY}Skipping system update.${C_NC}"
fi

echo "${C_YELLOW}📦 Installing LaTeX (fonts + icons + latexmk)...${C_NC}"

# Check packages with commands:
#   - `pacman -Ss latex | grep texlive`
#   - `pacman -Qsq 'texlive*'`
# | Packages                 | Description                                    |
# |--------------------------|------------------------------------------------|
# | latexmk                  | Auto-build tool for LaTeX                      |
# | texlive-binextra         | Core TeX engines (pdflatex, xelatex, lualatex) |
# | texlive-latex            | Standard LaTeX packages                        |
# | texlive-latexextra       | Extra packages (includes FontAwesome)          |
# | texlive-fontsextra       | Additional fonts for better PDF output         |
# | texlive-latexrecommended | Widely used packages (graphics, tables, etc.)  |
# | texlive-core             | Base LaTeX system                              |
# | texlive-xetex            | XeLaTeX engine (system font support)           |
# | texlive-luatex           | LuaLaTeX engine (modern alternative engine)    |
sudo pacman -S --needed --noconfirm \
    texlive-basic \
    texlive-bin \
    texlive-binextra \
    texlive-latex \
    texlive-latexextra \
    texlive-fontsextra \
    texlive-latexrecommended \
    texlive-pictures \
    texlive-core

echo "Verifying installation..."
latexmk --version

echo "${C_GREEN}Done. Ready for PDF, fonts, and FontAwesome.${C_NC}"
