class Wts < Formula
  desc "Git worktree + tmux session launcher for parallel Claude Code agents"
  homepage "https://github.com/maximilientyc/wts"
  url "https://github.com/maximilientyc/wts/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "2d7c467250a3c622776a2ac2fa2afbc0dcae2ddc84e4826040e5cb340ddfddb4"
  license "MIT"
  head "https://github.com/maximilientyc/wts.git", branch: "main"

  depends_on "fzf"
  depends_on "jq"
  depends_on "tmux"
  depends_on "tmuxinator"

  uses_from_macos "curl"
  uses_from_macos "perl"
  uses_from_macos "sqlite"
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

      Let every Claude Code agent in a wts session know about the others:
        wts setup claude --install

      Upgrading from 0.x: the state moves to SQLite on the first command.
      See https://github.com/maximilientyc/wts#upgrading-to-10

      Agent state, naming from a phrase and `wts brief` need Claude Code:
        brew install --cask claude-code
    EOS
  end

  test do
    assert_match "wts #{version}", shell_output("#{bin}/wts --version")
    assert_match "default", shell_output("#{bin}/wts layouts")
    assert_match opt_libexec.to_s, shell_output("#{bin}/wts setup tmux")
    assert_match "#{opt_libexec}/wts/wts-context", shell_output("#{bin}/wts setup claude")
    # A private state dir: `wts db` initializes the database, and must never
    # import or touch the state of the machine running the test.
    ENV["XDG_STATE_HOME"] = testpath/"state"
    assert_match (testpath/"state/wts/wts.db").to_s, shell_output("#{bin}/wts db path")
  end
end
