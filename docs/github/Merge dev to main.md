# Step 1 – Open a Pull Request (PR) in GitHub

-   Go to your repo on GitHub.

-   Click Pull requests → New pull request.

Base branch: main
Compare branch: dev

Review the file changes — make sure everything looks as you expect.

click "create pull request" button.

Give the PR a title

# Step 2 – Merge the PR

Since main has Require linear history turned on, you’ll probably only see Squash merge (and maybe Rebase).

Squash and merge is clean — it combines all your dev commits into one commit in main.

Click Squash and merge, then click confirm.

Step 5 – Sync local main
git switch main
git pull


✅ Done — now your main branch is updated with all your dev work, and your repo history stays tidy.

##  Conflict resolution notes

```
<<<<<<< dev        ← content from the branch you are merging (dev)
... your dev changes ...
=======           ← separator
... the current main content ...
>>>>>>> main       ← content from the branch you are on (main)
```
