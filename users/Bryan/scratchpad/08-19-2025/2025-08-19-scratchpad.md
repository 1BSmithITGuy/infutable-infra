# 2025-08-19

## Inbox

## Notes

fix scratchpad issue:

![alt text](image-1.png)

---
sh -c 'root="/srv/repos/infutable-infra/users/Bryan/scratchpad"; day="$(date +%F)"; dir="$root/$day"; file="$dir/$day.md"; mkdir -p "$dir/_img"; [ -f "$file" ] || printf "# %s\n\n## Inbox\n\n## Notes\n\n" "$day" > "$file"; code --new-window "$root"; sleep 0.3; code -r -g "$file"'

Open your scratchpad workspace (the root folder window).

Ctrl+, → switch to the Workspace tab.

Search: Markdown: Copy Files: Destination.

Click Add Item and enter:

Key (glob that matches your Markdown files):

**/*.md


Value (where to save the pasted file):

${documentDirName}/_img/${fileName}


This writes the JSON below into your .vscode/settings.json:

"markdown.copyFiles.destination": {
  "**/*.md": "${documentDirName}/_img/${fileName}"
}

sh -c 'root="/srv/repos/infutable-infra/users/Bryan/scratchpad"; day="$(date +%m-%d-%Y)"; dir="$root/$day"; file="$dir/$day.md"; mkdir -p "$dir/_img"; [ -f "$file" ] || printf "# %s\n\n## Inbox\n\n## Notes\n\n" "$day" > "$file"; code --new-window "$root"; sleep 0.3; code -r -g "$file"'
