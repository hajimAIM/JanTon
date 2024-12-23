
# JanTon

Simple and fast HTTP Server that returns streamable HLS live content from **TONTON**, allowing you to restream the content from their server directly.

---

## Features

- Provides streamable HLS live content.
- Lightweight and fast HTTP server.
- auto rotate and stream cache for seemless streaming.
- premium channel access (soon)

---

## Table of Contents

- [Features](#features)
- [Usage](#usage)
- [License](#license)

---

## Usage

1. URL:

   ```m3u
   // TV3
   #EXTINF:-1 tvg-id="103.astro" tvg-name="103.astro" tvg-logo="https://headend-api.tonton.com.my/v210/imageHelper.php?id=6420323:378:CHANNEL:IMAGE:png&w=150&appID=TONTON" group-title="TonTon" ch-number="103",103 TV3
   #EXTHTTP:{"accept":"*/*","accept-language":"en-US,en;q=0.9","origin":"https://watch.tonton.com.my","referer":"https://watch.tonton.com.my/","sec-ch-ua-mobile":"?0","sec-ch-ua-platform":"Windows","sec-fetch-dest":"empty","sec-fetch-mode":"cors","sec-fetch-site":"same-site","sec-gpc":"1","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
   https://janton.whacat.me/tonton/TV3

   // NTV7
   #EXTINF:-1 tvg-id="" tvg-name="" tvg-logo="https://headend-api.tonton.com.my/v210/imageHelper.php?id=6420324:378:CHANNEL:IMAGE:png&w=150&appID=TONTON" group-title="TonTon" ch-number="107",107 NTV7
   #EXTHTTP:{"accept":"*/*","accept-language":"en-US,en;q=0.9","origin":"https://watch.tonton.com.my","referer":"https://watch.tonton.com.my/","sec-ch-ua-mobile":"?0","sec-ch-ua-platform":"Windows","sec-fetch-dest":"empty","sec-fetch-mode":"cors","sec-fetch-site":"same-site","sec-gpc":"1","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
   https://janton.whacat.me/tonton/NTV7

   // TV8
   #EXTINF:-1 tvg-id="" tvg-name="" tvg-logo="https://headend-api.tonton.com.my/v210/imageHelper.php?id=6420325:378:CHANNEL:IMAGE:png&w=150&appID=TONTON" group-title="TonTon" ch-number="108",108 TV8
   #EXTHTTP:{"accept":"*/*","accept-language":"en-US,en;q=0.9","origin":"https://watch.tonton.com.my","referer":"https://watch.tonton.com.my/","sec-ch-ua-mobile":"?0","sec-ch-ua-platform":"Windows","sec-fetch-dest":"empty","sec-fetch-mode":"cors","sec-fetch-site":"same-site","sec-gpc":"1","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
   https://janton.whacat.me/tonton/TV8

   // TV9
   #EXTINF:-1 tvg-id="" tvg-name="" tvg-logo="https://headend-api.tonton.com.my/v210/imageHelper.php?id=6420326:378:CHANNEL:IMAGE:png&w=150&appID=TONTON" group-title="TonTon" ch-number="109",TV9 TV9
   #EXTHTTP:{"accept":"*/*","accept-language":"en-US,en;q=0.9","origin":"https://watch.tonton.com.my","referer":"https://watch.tonton.com.my/","sec-ch-ua-mobile":"?0","sec-ch-ua-platform":"Windows","sec-fetch-dest":"empty","sec-fetch-mode":"cors","sec-fetch-site":"same-site","sec-gpc":"1","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
   https://janton.whacat.me/tonton/TV9

   // DS (Drama Sangat)
   #EXTINF:-1 tvg-id="" tvg-name="" tvg-logo="https://headend-api.tonton.com.my/v210/imageHelper.php?id=6420342:378:CHANNEL:IMAGE:png&w=150&appID=TONTON" group-title="TonTon" ch-number="110",110 Drama Sangat
   #EXTHTTP:{"accept":"*/*","accept-language":"en-US,en;q=0.9","origin":"https://watch.tonton.com.my","referer":"https://watch.tonton.com.my/","sec-ch-ua-mobile":"?0","sec-ch-ua-platform":"Windows","sec-fetch-dest":"empty","sec-fetch-mode":"cors","sec-fetch-site":"same-site","sec-gpc":"1","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
   https://janton.whacat.me/tonton/DS

   // TVN
   #EXTINF:-1 tvg-id="" tvg-name="" tvg-logo="https://headend-api.tonton.com.my/v210/imageHelper.php?id=6430002:378:CHANNEL:IMAGE:png&w=150&appID=TONTON" group-title="TonTon" ch-number="111",111 TVN
   #EXTHTTP:{"accept":"*/*","accept-language":"en-US,en;q=0.9","origin":"https://watch.tonton.com.my","referer":"https://watch.tonton.com.my/","sec-ch-ua-mobile":"?0","sec-ch-ua-platform":"Windows","sec-fetch-dest":"empty","sec-fetch-mode":"cors","sec-fetch-site":"same-site","sec-gpc":"1","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
   https://janton.whacat.me/tonton/TVN
   ```

2. Use the stream URL in your preferred media player or client.

---

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
