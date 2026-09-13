class Wts < Formula
  desc "Git worktree + tmux session launcher for parallel Claude Code agents"
  homepage "https://github.com/maximilientyc/wts"
  url "https://github.com/maximilientyc/wts/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "67e123929347e84c266a4b873b0aa96fcf57b80f5a4636410b20d6c01a4c3a86"
  license "MIT"
  head "https://github.com/maximilientyc/wts.git", branch: "main"

  depends_on "fzf"
  depends_on "jq"
  depends_on "tmux"
  depends_on "tmuxinator"

  uses_from_macos "curl"
  uses_from_macos "perl"
  uses_from_macos "zsh"

  def install
    bin.install "bin/wts"
    (libexec/"wts").install Dir["libexec/wts/*"]
    pkgshare.install "share/wts/layouts", "examples"
    zsh_completion.install "completions/_wts"
  end

  def caveats
    <<~EOS
      tmux integration (switcher popup, `C-b :` then `wts …`):
        wts setup tmux >> ~/.tmux.conf

      Your own layouts go in ~/.config/wts/layouts (see: wts layouts).

      Agent state, naming from a phrase and `wts brief` need Claude Code:
        brew install --cask claude-code
    EOS
  end

  test do
    assert_match "wts #{version}", shell_output("#{bin}/wts --version")
    assert_match "default", shell_output("#{bin}/wts layouts")
    assert_match opt_libexec.to_s, shell_output("#{bin}/wts setup tmux")
  end
end
