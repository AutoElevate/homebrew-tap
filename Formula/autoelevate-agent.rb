# Homebrew formula TEMPLATE for the autoelevate-agent tap.
#
# CI (.github/workflows/linux-agent.yml) fills in the url, sha256 and version
# fields on a release tag and pushes the result to the tap repository
# AutoElevate/homebrew-tap as Formula/autoelevate-agent.rb. The release
# binaries it points at are published to that same repo's GitHub Releases.
# Do not edit the generated copy in the tap by hand.
#
# NB: the placeholder tokens below must appear ONLY on their field lines — the
# render step does a global sed for them, so keep them out of comments.
#
# Install (once the tap exists):
#   brew install autoelevate/tap/autoelevate-agent
# or
#   brew tap autoelevate/tap
#   brew install autoelevate-agent
class AutoelevateAgent < Formula
  desc "AutoElevate Linux agent - user-requestable temporary admin elevation"
  homepage "https://autoelevate.com"
  url "https://github.com/AutoElevate/homebrew-tap/releases/download/linux-agent-v0.0.5/autoelevate-agent-linux-x86_64.tar.gz"
  sha256 "58dda31b6e601d6023fc589747c1b3e73d8d68761ec5acebde7de47e638abc94"
  version "0.0.5"
  # Proprietary: Homebrew has no SPDX identifier for it.
  license :cannot_represent

  depends_on :linux

  def install
    bin.install "aeagentd"
    bin.install "ae-tray"
    # Reference copies of the native packaging assets (systemd unit, polkit
    # policy, .desktop autostart). Homebrew runs as a non-root user so it
    # cannot place these in /usr/share/polkit-1/actions/, /etc/xdg/autostart/,
    # or /etc/systemd/system/ itself; the caveats below tell the operator how
    # to wire them up.
    pkgshare.install Dir["packaging/*"]
  end

  service do
    run [opt_bin/"aeagentd", "run"]
    require_root true
    keep_alive true
    log_path var/"log/autoelevate/agent.log"
    error_log_path var/"log/autoelevate/agent.log"
  end

  def caveats
    <<~EOS
      AutoElevate runs as a root system service and manages /etc/sudoers.d
      drop-ins, so it must run as root. A system `sudo` (with visudo) is
      required.

      Homebrew installs the agent binaries under #{HOMEBREW_PREFIX}/bin but
      cannot place the polkit action or the tray autostart .desktop into
      system locations (it runs as your user, not root). To finish the
      install, run once:

        sudo install -m 0644 \\
          "#{opt_pkgshare}/polkit/com.cyberfox.autoelevate.policy" \\
          /usr/share/polkit-1/actions/
        sudo install -m 0644 \\
          "#{opt_pkgshare}/xdg-autostart/autoelevate-tray.desktop" \\
          /etc/xdg/autostart/

      Start and provision:
        sudo brew services start autoelevate-agent
        sudo aeagentd register --license-key <KEY> --company "<NAME>"
    EOS
  end

  test do
    assert_match "aeagentd", shell_output("#{bin}/aeagentd version")
  end
end
