import numpy as np
import pandas as pd
import os
import sys

OIDV4_CLASSES='class-descriptions-boxable.csv'
OIDV4_TEST='test-annotations-bbox.csv'
OIDV4_TRAIN='train-annotations-bbox.csv'
OIDV4_VALIDATION='validation-annotations-bbox.csv'

def get_class_id( csv_folder, class_name ):
	classes_csv_path=os.path.join(csv_folder, OIDV4_CLASSES)
	df=pd.read_csv(classes_csv_path, names=['LabelName','ClassName'])
	return df.loc[df['ClassName']==class_name].iloc[0]['LabelName']

def write_yolov3_txt_file(txt_df, output_txt_path):
	txt_df['class_name'] = 0
	txt_df = txt_df[['class_name','x','y','width','height']]
	print("Writting bbox file:{}".format(output_txt_path))
	txt_df.to_csv(output_txt_path, index=False, header=False, sep=' ')

def convert_to_txt(csv_folder, class_name, images_path):
	#for a single class, use this one
	class_id = get_class_id( csv_folder, class_name )

	train_csv_path=os.path.join(csv_folder, OIDV4_TRAIN)
	df = pd.read_csv(train_csv_path)
	# Select only the input class id and select a few values
	selected_data = pd.DataFrame(df.loc[df['LabelName'] == class_id][['ImageID','XMin','XMax','YMin','YMax']])
	selected_data['width'] = selected_data['XMax'] - selected_data['XMin']
	selected_data['height'] = selected_data['YMax'] - selected_data['YMin']
	selected_data['x'] = (selected_data['XMax'] + selected_data['XMin'])/2
	selected_data['y'] = (selected_data['YMax'] + selected_data['YMin'])/2
	# Final data frame with only the required data
	final_data = pd.DataFrame(selected_data[['ImageID','x','y','width','height']])

	# iterate images to generate yolov3 bounding box files
	for root, dirs, files in os.walk(images_path):  
		for filename in files:
			if filename.endswith(".jpg"):
				image_id = filename[:-4]
				txt_df = pd.DataFrame(final_data.loc[final_data['ImageID'] == image_id])
				output_txt_path = os.path.join(images_path, image_id+".txt")
				write_yolov3_txt_file(txt_df, output_txt_path)
				

convert_to_txt(sys.argv[1], sys.argv[2], sys.argv[3])