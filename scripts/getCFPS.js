const { execSync } = require("child_process");
const Fs = require("fs");
const Path = require("path");
const Puppeteer = require("puppeteer");

(async () => {
    const browser = await Puppeteer.launch({headless: true});
    const page = await browser.newPage();
    await page.goto("https://github.com/DeFiCh/dfips/issues/199");
    await page.waitForFunction(() => document.readyState === "complete");
    // gid of the div of the post
    const gid = "IC_kwDOES_b885I9Wlt";
    const as = await page.$x("//div[@data-gid='" + gid + "']//a[@class='issue-link js-issue-link']");
    console.log(as.length);
    for (const a of as) {
        const url = await (await a.getProperty("href")).jsonValue();
        const page2 = await browser.newPage();
        await page2.goto(url);
        const title = await page2.title();
        await page2.close();
        const toMatch = "· Issue ";
        const toKeep = title.indexOf(toMatch) - 1;
        console.log(title.substring(0,11) + "|" + title.substring(13, toKeep) + "|" + url);
    }

    await page.close();
    await browser.close();
})();
