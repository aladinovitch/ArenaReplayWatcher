# ArenaReplayWatcher
This WoW AddOn is designed to facilitate the spectating of PvP Arena matches **2v2** **3v3** and **SoloQ**, for WotLK (3.3.5a) client. This tool enables users to initiate spectator mode via interaction with a dedicated in-game NPC.

## Usage and Data Input
The Arena Replay Watcher (ARW) AddOn is designed for efficient bulk processing of arena match IDs. It operates by accepting a **Comma-Separated Value (CSV)** formatted string containing pairs of Player Names and Match IDs.
1. Launching the AddOn
Access the ARW input interface using the chat command:
```
/arw
```
2. Required Input Format
The AddOn requires a strict input format where each entry is structured as:
```
Player_Name,Match_ID
```
3. Generating the Input String (Recommended Workflow)
To easily manage and generate the necessary input for multiple replays, it is highly recommended to use a spreadsheet application (e.g., Google Sheets, Microsoft Excel) and leverage its formula capabilities.

Create a table with the following structure:
| Player | Match ID | Watched | ARW Addon |
| :--- | :--- | :--- | :--- |
| Player name | Unique id for the match | A checkbox or status field | `=[@Player]&","&[@ID]` |

The last column contains the concatenated pair `Player,Match_ID` to be fed to the Addon.
Example of Excel formula `=[@Player]&","&[@ID]` concatenantes the two previous columns.

4. Example Data Structure
The resulting spreadsheet data should look like this (focusing on the final required output column):

| Player | Match ID | Watched | ARW Addon |
| :--- | :--- | :--- | :--- |
| Trapgirl |	39821232 |	Yes	| Trapgirl,39821232 |
| Trapgirl	| 39821252	| Yes	| Trapgirl,39821252 |
| Istackagi | 39826211 | No | Istackagi,39826211 |
| Istackagi |	39826246 |	No	| Istackagi,39826246 |
| Elssisqt |	39831818	| No |	Elssisqt,39831818 |
| Elssisqt |	39831879 |	No | Elssisqt,39831879 |
| Jamesjohnson |	39826211 |	No	| Jamesjohnson,39826211 |
| Jamesjohnson |	39826246	| No |	Jamesjohnson,39826246 |

To use the data: Copy the entire list of values from the #ARW Addon# column and paste them into the AddOn window after running `/arw`.

## 🎬 Video Guide: Full Addon Guide: Setup, Data Import, and Arena Study Workflow
Watch the video below for a complete walkthrough on how to install the addon, configure your server settings, import match data from your spreadsheet, and begin tracking opponents in-game.

[![Watch the Full Guide on YouTube](https://img.youtube.com/vi/ZvIf_--QZbI/hqdefault.jpg)](https://youtu.be/ZvIf_--QZbI)

**Support:** If you find this AddOn useful, please consider supporting its development via the **'Sponsor' button** on this repository page.
