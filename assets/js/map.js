let Map = {
    mounted() {
        this.initState();
        this.loadUniverse();
        this.prepDrawingContext();
        // this.scaleDrawing();
        this.drawUniverse();
    },

    updated() {
        this.drawUniverse();
    },

    initState() {
        this.sizes = {};
        this.offsets = {};
    },

    loadUniverse() {
        const universe = JSON.parse(this.el.dataset.universe);
        this.sectors = universe.sectors;
        this.sizes.xRange = universe.x_range;
        this.sizes.yRange = universe.y_range;
        this.offsets.xCoordinate = -universe.min_x;
        this.offsets.yCoordinate = -universe.min_y;
    },

    prepDrawingContext() {
        this.ctx = this.el.getContext("2d");

        this.ctx.font = "16px serif";
        this.ctx.textAlign = "center";
        this.ctx.textBaseline = "middle";

        const maxSectorName = this.ctx.measureText("99999");
        const maxSectorWidth =
              Math.abs(maxSectorName.actualBoundingBoxLeft) +
              Math.abs(maxSectorName.actualBoundingBoxRight);
        const maxSectorHeight =
              Math.abs(maxSectorName.actualBoundingBoxAscent) +
              Math.abs(maxSectorName.actualBoundingBoxDescent);

        this.sizes.sector = maxSectorWidth;
        if (maxSectorHeight > maxSectorWidth) {
            this.sizes.sector = maxSectorHeight;
        }
        const padding = 10;
        this.sizes.sector = Math.ceil(this.sizes.sector) + padding;
        this.sizes.halfSector = this.sizes.sector / 2;

        this.sizes.halfHexSide =
            this.sizes.halfSector / Math.tan(60 * Math.PI / 180);
        this.offsets.hexPoints = [
            [this.sizes.halfSector,
             -this.sizes.halfSector + this.sizes.halfHexSide],
            [this.sizes.sector, this.sizes.halfSector - this.sizes.halfHexSide],
            [this.sizes.sector, this.sizes.halfSector + this.sizes.halfHexSide],
            [this.sizes.halfSector,
             this.sizes.sector + this.sizes.halfSector -
                 this.sizes.halfHexSide],
            [0, this.sizes.halfSector + this.sizes.halfHexSide],
            [0, this.sizes.halfSector - this.sizes.halfHexSide]
        ];

        this.sizes.universeWidth = this.sizes.xRange * this.sizes.sector +
            this.sizes.halfSector + 1;
        this.sizes.universeHeight = this.sizes.yRange * this.sizes.sector +
            this.sizes.halfSector + this.sizes.halfSector / 2;

        this.pushEvent("record_drawing_sizes", {
            canvas_width: this.el.width,
            canvas_height: this.el.height,
            sector_size: this.sizes.sector
        });
    },

    scaleDrawing() {
        // Early scaling work:
        const universeSize = Math.ceil(
            100 * this.sizes.sector + this.sizes.halfSector +
                this.sizes.halfHexSide
        );
        const minScale = this.el.height / universeSize;
        this.ctx.scale(minScale, minScale);
    },

    drawUniverse() {
        this.ctx.clearRect(0, 0,
                           this.sizes.universeWidth, this.sizes.universeHeight);

        this.ctx.save();
        this.ctx.translate(1, this.sizes.halfSector / 2);

        const viewX = parseInt(this.el.dataset.viewX);
        const viewY = parseInt(this.el.dataset.viewY);
        this.ctx.save();
        this.ctx.translate(-viewX * this.sizes.sector,
                           -viewY * this.sizes.sector);

        for (var number in this.sectors) {
            var sector = this.sectors[number];
            var x = sector.coordinates[0] + this.offsets.xCoordinate;
            var y = sector.coordinates[1] + this.offsets.yCoordinate;
            var hexRowOffset = 0;
            if (Math.abs(sector.coordinates[1]) % 2 === 1) {
                hexRowOffset = this.sizes.halfSector;
            }

            // this.ctx.beginPath();
            // this.ctx.moveTo(
            //     hexRowOffset + x * this.sizes.sector +
            //         this.offsets.hexPoints[0][0],
            //     y * this.sizes.sector + this.offsets.hexPoints[0][1]
            // );
            // for (var i = 1; i < this.offsets.hexPoints.length; i++) {
            //     this.ctx.lineTo(
            //         hexRowOffset + x * this.sizes.sector +
            //             this.offsets.hexPoints[i][0],
            //         y * this.sizes.sector + this.offsets.hexPoints[i][1]
            //     );
            // }
            // this.ctx.closePath();
            // this.ctx.stroke();

            var centerX = hexRowOffset + x * this.sizes.sector +
                          this.sizes.halfSector;
            var centerY = y * this.sizes.sector + this.sizes.halfSector;
            this.ctx.fillText(sector.number, centerX, centerY);

            this.ctx.save();
            this.ctx.strokeStyle = "#999";
            for (var toNumber of sector.connections) {
                var to = this.sectors[toNumber.toString()];
                var toX = to.coordinates[0] + this.offsets.xCoordinate;
                var toY = to.coordinates[1] + this.offsets.yCoordinate;
                var toCenterX = toX * this.sizes.sector +
                                this.sizes.halfSector;
                var toCenterY = toY * this.sizes.sector +
                                this.sizes.halfSector;
                if (Math.abs(to.coordinates[1]) % 2 === 1) {
                    toCenterX = toCenterX + this.sizes.halfSector;
                }
                this.ctx.beginPath();
                this.ctx.moveTo(centerX, centerY);
                this.ctx.lineTo(toCenterX, toCenterY);
                this.ctx.stroke();
            }
            this.ctx.restore();
        }

        this.ctx.restore();
        this.ctx.restore();
    }
};

export default Map;
