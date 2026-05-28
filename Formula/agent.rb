# Homebrew formula TEMPLATE.
#
# CI (.github/workflows/linux-agent.yml) fills in the url, sha256 and version
# fields on a release tag and pushes the result to the tap repository
# AutoElevate/homebrew-tap as Formula/agent.rb. The release binaries it points
# at are published to that same repo's GitHub Releases. Do not edit the
# generated copy in the tap by hand.
#
# NB: the placeholder tokens below must appear ONLY on their field lines — the
# render step does a global sed for them, so keep them out of comments.
#
# Install (once the tap exists):
#   brew install autoelevate/tap/agent
# or
#   brew tap autoelevate/tap
#   brew install agent
class Agent < Formula
  desc "AutoElevate Linux agent - user-requestable temporary admin elevation"
  homepage "https://autoelevate.com"
  url "https://github.com/AutoElevate/homebrew-tap/releases/download/linux-agent-v0.0.3/autoelevate-agent-linux-x86_64.tar.gz"
  sha256 "5c58b6da5f366eb2d7c4a6c247ee402f985566ee749db123bc599ba712853db5"
  version "0.0.3"
  # Proprietary: Homebrew has no SPDX identifier for it.
  license :cannot_represent

  # System administration tool; Linux only. The native .deb/.rpm packages are
  # the production channel - this tap is primarily for evaluation/dev.
  depends_on :linux

  def install
    bin.install "aeagentd"
    bin.install "ae-tray"
    # Reference copies of the native packaging assets (systemd unit, polkit
    # policy, .desktop autostart) for operators who want them.
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
      required. For production fleet deployment prefer the native .deb/.rpm
      packages; this tap is primarily for evaluation.

      Start and provision:
        sudo brew services start agent
        sudo aeagentd register --license-key <KEY> --company "<NAME>"
    EOS
  end

  test do
    assert_match "aeagentd", shell_output("#{bin}/aeagentd version")
  end
end
