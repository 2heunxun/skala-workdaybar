# WorkdayBar

메뉴바에 이미지가 하나 떠 있습니다. 출근 시각에는 거의 투명하고, 퇴근 시각이 다가올수록 점점 선명하게 차올라서 오늘 하루 얼마나 남았는지 한눈에 보여줍니다.

A macOS menu bar icon that starts almost transparent when you clock in, and gradually fills in as your workday progresses — a glanceable indicator of how much of the day is left.

![WorkdayBar running in the real macOS menu bar](docs/screenshot-real.png)

> 실제 macOS 메뉴바에서 동작하는 화면입니다. 로고의 "S" 부분만 선명하고 나머지는 흐릿하게 남아있는 게 지금까지의 진행률입니다.
> WorkdayBar running in an actual macOS menu bar. Only the "S" is fully opaque — the rest stays dim — reflecting how much of the day has elapsed so far.

![WorkdayBar icon filled to 45% with a custom logo](docs/screenshot-example.png)

> 45% 진행된 상태를 커스텀 로고 예시로 렌더링한 화면입니다 (앱의 실제 아이콘 합성 로직으로 생성).
> Rendered with the app's actual icon-compositing logic at 45% progress, using a custom logo as an example.

![WorkdayBar after clock-out, showing overtime elapsed](docs/screenshot-overtime.png)

> 퇴근 시각이 지난 뒤의 실제 화면입니다. 아이콘은 꽉 찬 상태로 유지되고, "추가공부 X시간 Y분 하는 중"으로 퇴근 후 경과 시간을 보여줍니다.
> The real menu bar after clock-out time has passed. The icon stays fully filled, and the dropdown shows "추가공부 X시간 Y분 하는 중" (studying extra X hours Y minutes) — how long you've been at it since clocking out.

---

## 한국어

### 설치 방법

#### 1. DMG 다운로드 (권장)

1. [Releases](../../releases) 페이지에서 최신 `WorkdayBar-vX.Y.Z.dmg`를 내려받습니다.
2. DMG를 열고 `WorkdayBar.app`을 `Applications` 폴더로 드래그합니다.
3. **⚠️ 첫 실행 시 "확인되지 않은 개발자" 경고가 뜹니다.** 이 앱은 Apple 개발자 프로그램에 가입하지 않은 상태로 ad-hoc 서명만 되어 있어 Gatekeeper가 경고를 띄웁니다. 아래 두 방법 중 하나로 우회하세요.
   - **방법 A**: Finder에서 `WorkdayBar.app`을 우클릭(또는 Control+클릭) → **열기** → 다시 뜨는 대화상자에서 **열기**를 클릭합니다.
   - **방법 B**: 터미널에서 격리 속성을 제거합니다.
     ```bash
     xattr -dr com.apple.quarantine /Applications/WorkdayBar.app
     ```

#### 2. Homebrew Cask

```bash
brew install --cask 2heunxun/tap/workdaybar
```

별도 tap 저장소에 `Casks/workdaybar.rb`([이 저장소의 파일](Casks/workdaybar.rb) 참고)를 등록해야 합니다. 릴리즈 후 실제 DMG의 SHA256으로 플레이스홀더를 교체하세요.

#### 3. 소스에서 빌드

```bash
git clone https://github.com/2heunxun/skala-workdaybar.git
cd skala-workdaybar
./Scripts/build-app.sh
open WorkdayBar.app
```

### 사용법

메뉴바 아이콘을 클릭 → **설정…**을 열면:

- **출근 시각 / 퇴근 시각** — 이 시간을 기준으로 진행률이 계산됩니다.
- **이미지 선택…** — 회사 로고, 팀 마스코트 등 원하는 이미지를 PNG/JPG로 선택하면 즉시 메뉴바 아이콘으로 반영됩니다. 이게 이 앱의 핵심 사용 흐름입니다 — 기본 이미지는 그냥 예시일 뿐, 자기 이미지를 넣어야 진짜 재미있어집니다. 바로 테스트해보고 싶다면 [`docs/example-logo.png`](docs/example-logo.png)를 골라보세요.
- **미경과 구간 투명도 / 채움 방향 / 주말 숨김 / 로그인 시 자동 실행** — 취향껏 조정하세요.

### 앱이 사라졌을 때 / 재부팅 후 자동으로 뜨게 하기

메뉴바 아이콘을 실수로 종료했거나 앱이 죽었다면, 다른 Mac 앱처럼 다시 열면 됩니다 (Dock 아이콘이 없는 메뉴바 전용 앱이라 Dock에서는 못 엽니다):

- **Spotlight**: `Cmd + Space` → "WorkdayBar" 입력 → Enter
- **Launchpad**에서 아이콘 클릭
- **Finder → Applications** 폴더에서 `WorkdayBar.app` 더블클릭

컴퓨터를 껐다 켜도(재부팅) 자동으로 다시 뜨게 하려면, 메뉴 → **설정…** → **"로그인 시 자동 실행"** 토글을 켜세요. 기본값은 꺼짐이라, 이 토글을 켜지 않으면 재부팅 후 매번 위 방법으로 직접 열어야 합니다. (실행 중에 앱이 죽었을 때 자동으로 재시작해주는 기능은 아니고, 로그인/재부팅 시점에만 자동으로 켜주는 기능입니다.)

### 기여 가이드

이슈와 PR 환영합니다. 커밋 메시지는 [Conventional Commits](https://www.conventionalcommits.org/) 형식을 따라주세요 (`feat:`, `fix:`, `docs:` 등). 로컬에서 `swift build`와 `swift test`가 통과하는지 확인한 뒤 PR을 올려주세요.

### 라이선스

[MIT License](LICENSE)

---

## English

### Installation

#### 1. Download the DMG (recommended)

1. Grab the latest `WorkdayBar-vX.Y.Z.dmg` from the [Releases](../../releases) page.
2. Open the DMG and drag `WorkdayBar.app` into `Applications`.
3. **⚠️ You'll see an "unidentified developer" warning on first launch.** This app is only ad-hoc signed (no paid Apple Developer Program membership), so Gatekeeper flags it. Bypass it with either method below.
   - **Method A**: In Finder, right-click (or Control-click) `WorkdayBar.app` → **Open** → click **Open** again in the dialog that appears.
   - **Method B**: Remove the quarantine attribute from the terminal:
     ```bash
     xattr -dr com.apple.quarantine /Applications/WorkdayBar.app
     ```

#### 2. Homebrew Cask

```bash
brew install --cask 2heunxun/tap/workdaybar
```

Requires registering [`Casks/workdaybar.rb`](Casks/workdaybar.rb) in a separate tap repository. Replace the placeholder SHA256 with the real DMG checksum after each release.

#### 3. Build from source

```bash
git clone https://github.com/2heunxun/skala-workdaybar.git
cd skala-workdaybar
./Scripts/build-app.sh
open WorkdayBar.app
```

### Usage

Click the menu bar icon → **Settings…**:

- **Clock-in / clock-out time** — progress is calculated against this window.
- **Choose Image…** — pick a company logo, team mascot, or anything else as a PNG/JPG; it becomes your menu bar icon immediately. This is the whole point of the app — the bundled default is just a placeholder, swap in your own image to make it yours. Want to try it right away? Pick [`docs/example-logo.png`](docs/example-logo.png).
- **Unfilled opacity / fill direction / hide on weekends / launch at login** — tune to taste.

### If the app disappears / auto-start after a restart

If you accidentally quit the menu bar icon or it crashed, just relaunch it like any other Mac app (there's no Dock icon to click, since it's a menu-bar-only app):

- **Spotlight**: `Cmd + Space` → type "WorkdayBar" → Enter
- Click it in **Launchpad**
- Double-click `WorkdayBar.app` in **Finder → Applications**

To have it come back automatically after turning your computer off and on (a restart), open the menu → **Settings…** → enable **"Launch at Login"**. This is off by default, so without enabling it you'll need to reopen it manually every time after a restart. (This only relaunches the app at login/restart — it won't automatically restart the app if it crashes while your Mac stays on.)

### Contributing

Issues and PRs welcome. Please follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, etc.) for commit messages, and make sure `swift build` and `swift test` pass locally before opening a PR.

### License

[MIT License](LICENSE)
