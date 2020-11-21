// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {};
Hooks.Map = {
    mounted() {
        const canvas = this.el;
        const ctx = canvas.getContext("2d");

        ctx.font = "16px serif";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";

        const maxSectorMeasurement = ctx.measureText("99999");
        const maxSectorWidth =
              Math.abs(maxSectorMeasurement.actualBoundingBoxLeft) +
              Math.abs(maxSectorMeasurement.actualBoundingBoxRight);
        const maxSectorHeight =
              Math.abs(maxSectorMeasurement.actualBoundingBoxAscent) +
              Math.abs(maxSectorMeasurement.actualBoundingBoxDescent);
        var maxSectorSize = maxSectorWidth;
        if (maxSectorHeight > maxSectorWidth) {
            maxSectorSize = maxSectorHeight;
        }
        const padding = 10;
        maxSectorSize = Math.ceil(maxSectorSize) + padding;
        const sectorCenter = maxSectorSize / 2;

        const halfHexSide = sectorCenter / Math.tan(60 * Math.PI / 180);
        const hexPointOffsets = [
            [sectorCenter, -sectorCenter + halfHexSide],
            [maxSectorSize, sectorCenter - halfHexSide],
            [maxSectorSize, sectorCenter + halfHexSide],
            [sectorCenter, maxSectorSize + sectorCenter - halfHexSide],
            [0, sectorCenter + halfHexSide],
            [0, sectorCenter - halfHexSide]
        ];
        ctx.translate(1, halfHexSide);

        const universe = JSON.parse(canvas.dataset.universe);

        // Early scaling work:
        // const universeSize = Math.ceil(
        //   100 * maxSectorSize + sectorCenter + halfHexSide
        // );
        // const minScale = canvas.height / universeSize;
        // ctx.scale(minScale, minScale);

        for (var y = 0; y < 100; y++) {
            for (var x = 0; x < 100; x++) {
                var offset = 0;
                if (y % 2 === 1) {
                    offset = sectorCenter;
                }

                ctx.beginPath();
                ctx.moveTo(
                    offset + x * maxSectorSize + hexPointOffsets[0][0],
                    y * maxSectorSize + hexPointOffsets[0][1]
                );
                for (var i = 1; i < hexPointOffsets.length; i++) {
                    ctx.lineTo(
                        offset + x * maxSectorSize + hexPointOffsets[i][0],
                        y * maxSectorSize + hexPointOffsets[i][1]
                    );
                }
                ctx.closePath();
                ctx.stroke();

                ctx.fillText(
                    universe[y][x],
                    offset + x * maxSectorSize + sectorCenter,
                    y * maxSectorSize + sectorCenter
                );
            }
        }
    }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket(
    "/live",
    Socket,
    {params: {_csrf_token: csrfToken}, hooks: Hooks}
);

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start());
window.addEventListener("phx:page-loading-stop", info => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
