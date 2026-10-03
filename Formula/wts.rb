class Wts < Formula
  desc "Git worktree + tmux session launcher for parallel Claude Code agents"
  homepage "https://github.com/maximilientyc/wts"
  url "https://github.com/maximilientyc/wts/archive/refs/tags/v1.8.2.tar.gz"
  sha256 "6e648ec50e491b03a0ba9b51166ee2e78039553a625bceb30089b863de459a40"
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
    pkgshare.install "share/wts/layouts", "share/wts/skill", "examples"
    zsh_completion.install "completions/_wts"
  end

  def caveats
    <<~EOS
      tmux integration (switcher popup, `C-b :` then `wts …`), written between
      markers in ~/.tmux.conf and replaced on the next upgrade:
        wts setup tmux --install

      Your own layouts go in ~/.config/wts/layouts (see: wts layouts).

      Let every Claude Code agent know about wts and about the others (hooks,
      permissions for the read-only verbs, and the wts skill):
        wts setup claude --install

      After an upgrade, `wts doctor` says what is out of date.

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
    assert_match "wts-hook touch", shell_output("#{bin}/wts setup claude")
    assert_path_exists pkgshare/"skill/SKILL.md"
    # A private state dir: `wts db` initializes the database, and must never
    # import or touch the state of the machine running the test.
    ENV["XDG_STATE_HOME"] = testpath/"state"
    assert_match (testpath/"state/wts/wts.db").to_s, shell_output("#{bin}/wts db path")
  end
end
