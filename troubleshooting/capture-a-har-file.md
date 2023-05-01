---
description: Steps to Capture HAR file for troubleshooting
---

# Capture a HAR File

### **What is a HAR file?**

A HAR file is used mainly for identifying performance issues, such as bottlenecks, slow load times, or page rendering problems.  It is frequently used by developers and security researchers to analyze and detect vulnerabilities, supervises every resource loaded by the browser together with timing information for each resource. Several HTTP-related tools such as Electron HAR, HttpWatch, and HTTP Toolkit can export HAR files, but these files are usually exported by web browsers. The majority of browsers support the format including including Google Chrome, Mozilla Firefox, and Safari.

Below are the steps to generate the HAR file from the most commonly-used browsers.

### **Generate a HAR file in Google Chrome**

1. Open Chrome and go to the page where the issue is occurring.
2. Look for the vertical dots icon and select _More Tools > Developer Tools_.
3.  From the panel that appears, select the _Network_ tab.\
    \
    Optional: If Zendesk Customer Support requests a HAR file with WebSockets, select the _WS_ option in the Network tab. Reload your browser to start seeing the traffic over the WebSocket.\


    <figure><img src="https://support.zendesk.com/hc/article_attachments/5214136080922" alt=""><figcaption></figcaption></figure>
4. Look for a round record button in the upper left corner of the tab, and make sure it is red. If it is grey, click the button once to start recording.
5. Check the box _Preserve log._
6. Select the clear button to clear any existing logs from the network tab.
7. Reproduce the issue while the network requests are recorded.
8.  Select the download icon > _Export HAR_ to download, and save the file to your local device: _Save as HAR with Content_.\


    ![download buttom from network tab in chrome](https://support.zendesk.com/hc/article\_attachments/5213499974938)
9. You're done! Please attach the HAR file to your email or case with us so that we can assist further.

### Generate a HAR file in Mozilla Firefox

1. Press F12 on your keyboard
2. Select the _Network_ tab.
3. To the top right of the console, select the gear icon, then select _Persist Logs._

<figure><img src="https://mhedu.force.com/CXG/servlet/rtaImage?eid=ka68b0000008cRA&#x26;feoid=00N0y000006XYSa&#x26;refid=0EM8b000005QzUj" alt=""><figcaption></figcaption></figure>

4. Leave the network tab open, and in the browser page reproduce the issue.
5. After you have reproduced the issue, right-click on any line and select _Save all as HAR._

![image.png](https://mhedu.force.com/CXG/servlet/rtaImage?eid=ka68b0000008cRA\&feoid=00N0y000006XYSa\&refid=0EM8b000005QzW1)

5. You're done! Please attach the HAR file to your email or case with us so that we can assist further.

### Generate a HAR file in Safari

1. Open Safari.
2. In Safari, go to the affected webpage.
3. To enable Developers Tool: _Safari_ > _Preferences_ > _Advanced_, then select _Show Develop menu in menu bar_
4. Select _Develop_ > _Show Web Inspector_ > _Network._
5. Within the Network tab, select the _Preserve log_ option.
6. Refresh the page to replicate the error and allow Safari to record the browser-website interaction.&#x20;
7. Once the page is loaded, select _Export_ on the top right in the window of the Network tab.
8. Select the _Console_ tab and screen capture the errors.
