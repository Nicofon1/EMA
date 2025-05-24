'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "452f3293a62cb736b285940b3302df1e",
".git/config": "06641ec0a609f2940dcb19cbdcb078b0",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "9dcdb50ca4e39469b5d708c1b74d47d9",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "bf0ed651faf3bd53b20d6e482258918a",
".git/logs/refs/heads/main": "cd3c09a60b9ad8575984814a33b01061",
".git/logs/refs/remotes/origin/main": "3bc4f07eee4f3cb8dc5251ac99bfbeb7",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/05/0af47d84241f3a5f22ac7fd8490e7893075b87": "bc941551f163c695029ca19f59d46055",
".git/objects/08/f69444b4e54fc209362b5c61cc2b5e7b99ba23": "794b90fa98bec2e6766acddae4bde6a4",
".git/objects/11/d7de79e7a55db0af48603aee42d070fc9ce5da": "0ee50fb7dc85c8e2dfd8f8cc1608a597",
".git/objects/13/fda99d585075a80ca5c056cd1626b2d0cc7aed": "d09d6c6458d6eec6c318b810b965337d",
".git/objects/18/1680012b8b7df888c8158e82ad98afe3e166e2": "07d88024f197da1018d73f2b01a6d951",
".git/objects/1e/958b3dd8029d8dda04bc9a5a05117be06dc24a": "3a41ba81c8ad9e8e76c390de747e40e6",
".git/objects/2b/9dce81cf754aedecc43abc0c5ece457f612da9": "0486da3821fee8e305069034063cecf8",
".git/objects/33/31d9290f04df89cea3fb794306a371fcca1cd9": "e54527b2478950463abbc6b22442144e",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/3f/a929c68b924964304ac19601b46059859e0854": "d37fd9c2629fc79023f15af3abab4540",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/46/c3f1812e94a1e353f687a728c7bf1172db817f": "bccb1549f9544aa2fec973e3e794ab03",
".git/objects/49/1923b1c55ace951e5362d56cdf86a9262791a8": "0a2c7fe3524e70c1b10db1296bd5e1b7",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/4f/19d88f601b8a27f3fae374e49afacdb0709db5": "bd4f76ae24e3cdcad979a70e6e379a29",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/5c/255f21bec1f2e94197e55a41685ff7e128a243": "7043d7667fa3a36f8bb58c210da7a346",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/62/23d0f826b398c1e3487087c8412a13874741c2": "41704b89a90038b156507ce91a886aae",
".git/objects/64/5116c20530a7bd227658a3c51e004a3f0aefab": "f10b5403684ce7848d8165b3d1d5bbbe",
".git/objects/68/fe0b14764307ebdb5dfca4d3938427cdf4e41a": "fcf6a1539cd7742d34aefd39d93d1e10",
".git/objects/6e/a9b0e2e55c469a7a99f9b8728c65930a8bb589": "b74f8e7a7c4f05bfc58a791a41ffbcc6",
".git/objects/7e/3bb2f8ce7ae5b69e9f32c1481a06f16ebcfe71": "4ac6c0fcf7071bf9fc9c013172f9996f",
".git/objects/7f/6f78adce7a50f6750f9922148d0b8b9e25cba6": "2d7034f8d334e6fa39471d8e4607cfb1",
".git/objects/81/0e74c9899a1e2e3e2dafdb7643eb91d29deecd": "7da18d64fafb4d49db16ef41dbd61a4d",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/93/bade245ed03b3a9e71ec67fbd4def68de36d2e": "7a36e4d74f8c5f7795f36dcd47066907",
".git/objects/93/be7fd9b9dcdd8564dafd7040a0c8c8f68d4080": "b27ff257c793a735fc818ff37f392ff9",
".git/objects/a1/0d8dba172bbfae4e94dad1ecd2efa76d9fc495": "615f540adb391654e43f5834ff5a178f",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/a9/91f51138ffe059d588003dc7936aff059a0428": "b73a35563fa129bd884d8b5c53ee9231",
".git/objects/ab/05a3dbeb0ca7c747f105fc7963f45449cdcf61": "8b05d5d68119d0357d339d5d6d6608c3",
".git/objects/ad/2f90b78480aeb6608226d9db4ecbd3ec06aaeb": "4add97a99941aa0e9eed0f2173416ade",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/bc/7d993f94baf32ca11e5f5dc5412aac12a668a9": "d782f8a82d795ae96da7df117f4c51bd",
".git/objects/bf/804f7a7ece1a1816cfec1c267c2fb136eaa4ba": "6500c7d9067a998a5379263d688a7647",
".git/objects/c2/4c3a592b3afcb6b0a4ce82a5d214a42ec427c5": "e0878fdf74706c629097e92d655e13fd",
".git/objects/ca/28c42816e1ba98b5202e9a751a7a71c42d96e6": "963cafb9d7043e8a4b08248318128b18",
".git/objects/cc/fab74c1f56c330985060e2247607eaedb3c7d7": "ad5b6117df489509af208438785f208b",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/da/c6bbfa09a9a6370673cd500435b8ddc64843fc": "95d34ba5598a76b8209edc04601cc2ab",
".git/objects/dc/d51a15ff7b9ed3de11b8081114ec5af12daa15": "198d49ad920956a676c609dfb8f36edf",
".git/objects/e0/0d75bdcb809571476fbd018409cd12e3fdd110": "f5b7950bad65490ad3f52de9b75d528f",
".git/objects/e5/973e84a0c8f8031f2d040a757c722f2d34d31f": "255b68512e89327221814344e636f549",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ed/e64b5db356bbd3d2afc6998079d4d8d239afe6": "18ea3f37af100c80c0cca386e36b480a",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f4/fe0111b5593262d6f7653d69dcc4da57fac16f": "67d246f12d9f7c7f0a76e0a50696e29b",
".git/objects/f6/cc06a0d471df5df1f35082b09b45fced798d05": "b3ed116bd3c82d600d635270058f4345",
".git/objects/fb/da59bbf753f9caf3fe480472388e7190f22764": "2911d7180a8171c4512edea5fb851a34",
".git/refs/heads/main": "5dc22dbb262bd6882c6c946ea1a9333d",
".git/refs/remotes/origin/main": "5dc22dbb262bd6882c6c946ea1a9333d",
"assets/AssetManifest.bin": "817d7036a22625a4ea98152a68c74fb7",
"assets/AssetManifest.bin.json": "ccfabad859e402c90103147042affd46",
"assets/AssetManifest.json": "87bfc6e75d22e62c04b859729ac04fbb",
"assets/assets/fonts/Roboto-Regular.ttf": "303c6d9e16168364d3bc5b7f766cfff4",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "b0f1ef5a8c5f7cd2f59993f80e45e5b7",
"assets/jsonfile/modulos.json": "5439a5da87acd19ff784d6ff4805e459",
"assets/jsonfile/sondeo.json": "eb682ed28ec238dab2950c7dc2921510",
"assets/NOTICES": "1ac62c30d81aeba7e86db57cf15c21f3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "d7d83bd9ee909f8a9b348f56ca7b68c6",
"assets/packages/dash_chat_2/assets/bot.webp": "4615bee55ecd9b719b128b08c0dfb881",
"assets/packages/dash_chat_2/assets/placeholder.png": "ce1fece6c831b69b75c6c25a60b5b0f3",
"assets/packages/dash_chat_2/assets/profile_placeholder.png": "110df150ac0756dbf5f06a5a9bcedf70",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/videos/ema.svg": "b34e9b8e99877e5ee3540ac830c66dce",
"assets/videos/modulo1.mp4": "fe9f1195ecf18909a4e1a273812aef35",
"assets/videos/modulo2.mp4": "fe9f1195ecf18909a4e1a273812aef35",
"assets/videos/modulo3.mp4": "fe9f1195ecf18909a4e1a273812aef35",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "f26e78e65e3321c18115c5c8a50a9844",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "891427cf5b3cc4ac840e96f2591b0890",
"/": "891427cf5b3cc4ac840e96f2591b0890",
"main.dart.js": "3c384655d5af419e27dc4ce48590d7cb",
"manifest.json": "829a869a47183140f80fe666a47649c3",
"version.json": "204484f3a6476ba2e56e35ee6174277f"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
