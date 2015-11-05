# Glossary

## Application: 
An application database that contains image DNA’s (the image database), meta-information and various settings (including the functionality the application was created for matching or similarity).

## Application Key: 
Each application has a unique application key that is used to access the application.

## Bounce: 
Taking a single DNA from an image database and comparing it to all DNA in the same image database.

## Color Weight: 
Using LTU technologies similarity algorithm you can control the return results based on color weight. Using color weight, the search can be weighted on the colors of 
the entire image, entirely on the shapes of the image or any combination of the two.

## Duplicate & Clone: 
A duplicate image is one that is where exactly all pixels have the same value as in the comparison image, any modification such as coloring or resizing makes the image 
a clone.

## DNA & Signature: 
When an image has been indexed a binary string is generated called an image DNA or signature.

## Global Matching: 
A global match detects if two images are exactly or very nearly the same.

## Enrollment: 
Reference to the entire process of taking an image, indexing it to generate a DNA, storing the DNA and keywords, generating and storing a thumbnail and reference image to an 
application.

## Image Database: 
Each application has its own database storage, in which a DNA is stored

## Image DNA Type: 
Each DNA is designed for a specific feature (matching or similarity).

## Image_ID: 
The image_id is a unique key to the user's image within an application and for a client. The image_id can be thought of as a foreign key to the container's database. The 
system will not accept duplicate image_id..

## Indexation: The act of processing an image by an algorithm to generate a DNA.

## Keywords: Each image entity may have a set of keywords (string) associated with it. These keywords are helpful for aiding and enhancing searches. Note: keywords may be duplicated across 
multiple images within a single image database but should not be duplicated on one image (eg. acceptable 'red,dog,bed', unacceptable 'red,red,red,dog,bed'.

## Local Matching: Local matching is able to find matching sub-sections of two images or images of the same object.
