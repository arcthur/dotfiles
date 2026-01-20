#!/bin/bash

app="${1:-}"
wechat_cn="$(printf '\u5fae\u4fe1')"
mail_cn="$(printf '\u90ae\u4ef6')"

case "$app" in
  "FaceTime")
    icon_result=":face_time:"
    ;;
  "Messages")
    icon_result=":messages:"
    ;;
  "VLC")
    icon_result=":vlc:"
    ;;
  "Notes")
    icon_result=":notes:"
    ;;
  "Things")
    icon_result=":things:"
    ;;
  "GitHub Desktop")
    icon_result=":git_hub:"
    ;;
  "App Store")
    icon_result=":app_store:"
    ;;
  "Google Chrome")
    icon_result=":google_chrome:"
    ;;
  "zoom.us")
    icon_result=":zoom:"
    ;;
  "Microsoft Word")
    icon_result=":microsoft_word:"
    ;;
  "Microsoft Teams")
    icon_result=":microsoft_teams:"
    ;;
  "WhatsApp")
    icon_result=":whats_app:"
    ;;
  "Microsoft Excel")
    icon_result=":microsoft_excel:"
    ;;
  "Microsoft PowerPoint")
    icon_result=":microsoft_power_point:"
    ;;
  "Numbers")
    icon_result=":numbers:"
    ;;
  "Default")
    icon_result=":default:"
    ;;
  "Element")
    icon_result=":element:"
    ;;
  "Bear")
    icon_result=":bear:"
    ;;
  "Notion")
    icon_result=":notion:"
    ;;
  "Calendar")
    icon_result=":calendar:"
    ;;
  "Xcode")
    icon_result=":xcode:"
    ;;
  "Slack")
    icon_result=":slack:"
    ;;
  "Sequel Pro")
    icon_result=":sequel_pro:"
    ;;
  "Bitwarden")
    icon_result=":bit_warden:"
    ;;
  "System Preferences")
    icon_result=":gear:"
    ;;
  "Discord")
    icon_result=":discord:"
    ;;
  "Dropbox")
    icon_result=":dropbox:"
    ;;
  "$wechat_cn")
    icon_result=":wechat:"
    ;;
  "Mail" | "$mail_cn")
    icon_result=":mail:"
    ;;
  "Safari")
    icon_result=":safari:"
    ;;
  "Telegram")
    icon_result=":telegram:"
    ;;
  "Keynote")
    icon_result=":keynote:"
    ;;
  "Spotify")
    icon_result=":spotify:"
    ;;
  "Figma")
    icon_result=":figma:"
    ;;
  "Spotlight")
    icon_result=":spotlight:"
    ;;
  "Music")
    icon_result=":music:"
    ;;
  "Pages")
    icon_result=":pages:"
    ;;
  "Obsidian")
    icon_result=":obsidian:"
    ;;
  "Zotero")
    icon_result=":zotero:"
    ;;
  "Reminders")
    icon_result=":reminders:"
    ;;
  "Preview")
    icon_result=":pdf:"
    ;;
  "Code")
    icon_result=":code:"
    ;;
  "Calibre")
    icon_result=":book:"
    ;;
  "Finder")
    icon_result=":finder:"
    ;;
  "Linear")
    icon_result=":linear:"
    ;;
  "Podcasts")
    icon_result=":podcasts:"
    ;;
  "Ghostty" | "Terminal")
    icon_result=":terminal:"
    ;;
  *)
    icon_result=":default:"
    ;;
esac
echo "$icon_result"
