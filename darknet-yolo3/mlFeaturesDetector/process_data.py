import os
import sys
import glob
import argparse
import numpy as np
import pandas as pd

OIDV4_CLASSES='class-descriptions-boxable.csv'
OIDV4_TEST='test-annotations-bbox.csv'
OIDV4_TRAIN='train-annotations-bbox.csv'
OIDV4_VALIDATION='validation-annotations-bbox.csv'

def get_class_id( class_name, csv_folder ):
	classes_csv_path=os.path.join(csv_folder, OIDV4_CLASSES)
	df=pd.read_csv(classes_csv_path, names=['LabelName','ClassName'])
	return df.loc[df['ClassName']==class_name].iloc[0]['LabelName']

def write_yolov3_txt_file(txt_df, output_txt_path):
	txt_df['class_name'] = 0
	txt_df = txt_df[['class_name','x','y','width','height']]
	print("Writting bbox file:{}".format(output_txt_path))
	txt_df.to_csv(output_txt_path, index=False, header=False, sep=' ')

def get_image_metadata(class_name, csv_folder):
	class_id = get_class_id( class_name, csv_folder )

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
	return final_data

def process_boundingboxes(data_frame, images_path):
	# iterate images to generate yolov3 bounding box files
	for root, dirs, files in os.walk(images_path):  
		for filename in files:
			if filename.endswith(".jpg"):
				image_id = filename[:-4]
				txt_df = pd.DataFrame(data_frame.loc[data_frame['ImageID'] == image_id])
				output_txt_path = os.path.join(images_path, image_id+".txt")
				write_yolov3_txt_file(txt_df, output_txt_path)

def write_images_file( output_file, images_path):
	with open(output_file, 'w') as file_train:  
		for filename in glob.iglob(os.path.join(images_path, "*.jpg")):  
			name, ext = os.path.splitext(os.path.basename(filename))
			file_train.write(os.path.join(images_path, name + '.jpg') + "\n")

def generate_dataset( train_images_path, test_images_path, validation_images_path, output_path ):
	print("Generating train and test data files")
	train_path = os.path.join(output_path,'train.txt')
	test_path = os.path.join(output_path,'test.txt')
	validation_path = os.path.join(output_path,'validation.txt')
	write_images_file( train_path, train_images_path)
	write_images_file( test_path, test_images_path)
	write_images_file( validation_path, validation_images_path)

def main():
	parser = argparse.ArgumentParser(description='Process different image sets to Darknet Yolo-v3')
	parser.add_argument('-d', '--dataset', default='oidv4', 
						help='What dataset type is going to use the tool to import and convert the data. Only supported "oidv4" for now')
	parser.add_argument('-c', '--config_output_path', default='./', help='Path where the train.txt and test.txt will be generated')
	parser.add_argument('class_name', help='Class name to process (for example "Traffic_light")')
	parser.add_argument('path', help='Path where the dataset has the images and metadata information. Use the root path for OpenImagesV4 (oidv4)')

	args = parser.parse_args()
	csv_folder = os.path.join(args.path, 'csv_folder')
	class_name = args.class_name.replace('_',' ')
	train_images_path = os.path.join(args.path, os.path.normpath('Dataset/train/{}'.format(class_name)))
	test_images_path = os.path.join(args.path, os.path.normpath('Dataset/test/{}'.format(class_name)))
	validation_images_path = os.path.join(args.path, os.path.normpath('Dataset/validation/{}'.format(class_name)))

	data_frame = get_image_metadata(class_name=class_name, csv_folder=csv_folder)
	process_boundingboxes(data_frame=data_frame, images_path=train_images_path)
	process_boundingboxes(data_frame=data_frame, images_path=test_images_path)
	process_boundingboxes(data_frame=data_frame, images_path=validation_images_path)
	generate_dataset(train_images_path, test_images_path, validation_images_path, args.config_output_path )

if __name__ == "__main__":
    # execute only if run as a script
    main()
