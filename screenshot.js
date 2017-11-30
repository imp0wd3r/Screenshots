const fs = require('fs')
const { URL } = require('url')
const readline = require('readline')
const puppeteer = require('puppeteer')

const file = process.argv[2]
const result_dir = process.argv[3]
const rl = readline.createInterface({
    input: fs.createReadStream(file)
})

rl.on('line', function (line) {
    (async () => {
        const browser = await puppeteer.launch();
        const page = await browser.newPage();
        if (line.startsWith('http://') || line.startsWith('https://')) {
            const urlparse = new URL(line)
            var name = urlparse.host
        } else {
            var name = line
            line = 'http://' + line
        }
        await page.goto(line);
        name = name.replace(':', '-');
        await page.screenshot({ path: result_dir  + '/' + name + '.png' });

        await browser.close();
    })()
})

process.on('unhandledRejection', (reason, p) => {
    setTimeout(function() {
        console.log('UnhandledRejection. Exit');
    }, 5000);
    process.exit()
});
