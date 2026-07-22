cask "workdaybar" do
  version "0.1.0"
  sha256 "REPLACE_WITH_SHA256_AFTER_RELEASE"

  url "https://github.com/<your-github-username>/skala-workdaybar/releases/download/v#{version}/WorkdayBar-v#{version}.dmg"
  name "WorkdayBar"
  desc "Menu bar icon that fills in as your workday progresses"
  homepage "https://github.com/<your-github-username>/skala-workdaybar"

  depends_on macos: ">= :ventura"

  app "WorkdayBar.app"

  zap trash: [
    "~/Library/Application Support/WorkdayBar",
    "~/Library/Preferences/com.workdaybar.app.plist",
  ]
end
