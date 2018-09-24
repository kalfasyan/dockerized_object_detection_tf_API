import os 
import xml.etree.ElementTree as ET 
import glob
#from natsort import natsorted

PATH_ANNT = os.path.join(os.path.dirname(os.path.abspath('__file__')), 'annotations')
PATH_IMGS = os.path.join(os.path.dirname(os.path.abspath('__file__')), 'images')

annt_list = os.listdir(PATH_ANNT)

for i, file in enumerate(annt_list):
	tree = ET.parse(os.path.join(PATH_ANNT,file))

	doc = tree.getroot()
	doc.find('folder').text = 'images'
	doc.find('path').text = os.path.join(PATH_IMGS, file[:-4] + '.png')
	tree.write(os.path.join(PATH_ANNT,file))
	#print(os.path.join(PATH_IMGS, file[:-4] + '.png'))
