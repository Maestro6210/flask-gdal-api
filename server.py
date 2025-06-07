from flask import Flask, request, send_file, abort
from flask_cors import CORS
import numpy as np
from osgeo import gdal, osr
import tempfile
import os
import traceback


app = Flask(__name__)
CORS(app)  # <-- Enable CORS for all routes and origins

@app.route('/create_tif', methods=['POST'])
def create_tif():
    try:
        data = request.json
        values = data.get('values')  # Expect 2D list of pixel values
        print("Received values:", values[:5])  # Preview first 5 values
        bounds = data.get('bounds')  # [minX, minY, maxX, maxY]
        filename = data.get('filename', 'output.tif')
        if not filename.lower().endswith('.tif'):
            filename += '.tif'

        if not values or not bounds:
            return abort(400, "Missing 'values' or 'bounds' in request.")
        rows = data.get('rows')  # You need to send rows and cols from client
        cols = data.get('cols')
        if not rows or not cols:
            return abort(400, "Missing 'rows' or 'cols' in request.")
        arr = np.array(values, dtype=np.uint16).reshape((rows, cols))
        print("Array min:", arr.min(), "max:", arr.max())

        minY, minX, maxY, maxX = bounds
        pixel_width = (maxX - minX) / cols
        pixel_height = (maxY - minY) / rows

        geotransform = (minX, pixel_width, 0, maxY, 0, -pixel_height)

        # Create a temporary file to store GeoTIFF
        temp_file = tempfile.NamedTemporaryFile(suffix='.tif', delete=False)
        temp_filename = temp_file.name
        temp_file.close()  # Close to allow GDAL to write

        driver = gdal.GetDriverByName('GTiff')
        dataset = driver.Create(temp_filename, cols, rows, 1, gdal.GDT_UInt16, options=["TILED=YES", "COMPRESS=LZW"])
        dataset.SetGeoTransform(geotransform)

        srs = osr.SpatialReference()
        srs.ImportFromEPSG(4326)  # WGS84 lat/lon
        dataset.SetProjection(srs.ExportToWkt())

        band = dataset.GetRasterBand(1)
        band.WriteArray(arr)
        band.FlushCache()
        band.SetNoDataValue(0)  # or some value not in your data

        dataset.FlushCache()
        dataset = None
        print(f"Array shape: {arr.shape}, dtype: {arr.dtype}")

        ds_test = gdal.Open(temp_filename)
        if ds_test is None:
            print("ERROR: TIFF not valid")
        else:
            print("TIFF generated successfully.")
            ds_test = None

        # Send file as downloadable response
        return send_file(temp_filename, as_attachment=True, download_name=filename)

    except Exception as e:
        traceback.print_exc()
        return abort(500, f"Server error: {str(e)}")

if __name__ == '__main__':
    app.run(port=5000)
