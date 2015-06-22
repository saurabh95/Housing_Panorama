# Housing_Panorama
Instructions to make Panorama images
- Use KRPano to divide stitched images into 6 images, so that each image can fit in one cube
- The output of the above step would generate a vtour directory which will be having panos directory, this will have many images, but only images with prefix mobile_ are required.
- Use `test/make_input.sh` to generate the required input folder
- To use this script type `./make_input.sh <path of panos directory generated by KRPano>`
- This will replace the contents of the panos folder with the required contents i.e. panos folder would now have a folder `i` (having fine images of size 1024x1024)  and `blur_i` (having blur images of size 256x256) where i is the `pano_id`
- Now copy this generated folder to the `test/Dataset`

Now you need to edit `test/config.js` as per your Dataset
- In this, `DirectPano` object needs to be filled with desired values
- `hotspots_angle` is an array in which element `i` contains the hotspots which would be present in the pano with `panoid = i`
- each hotspot is represented by an array of length 3, [0] -> panoid of the pano to which the hotspot links, [1] -> angle at which the hotspot is present, [2] -> distance at which hotspot is present
- `pano_path` is the path of the directory which is having pano images(which are made by running `make_input.sh`)
- `pano_div_id` is the name of the div element in which pano should be loaded
- `image_div_id` is the name of the div element in which the full screen image will be loaded(such that on clicking this image the pano becomes full screen)

To run this, do `./run.sh` (currently works only for OSX), this will make a `SimpleHTTPServer` at port 8000 and open a tab in the default browser