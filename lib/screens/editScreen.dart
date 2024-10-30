import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controllers/patientController.dart';

class EditPatientScreen extends StatefulWidget {
  @override
  _EditPatientScreenState createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final PatientController patientController = Get.find<PatientController>();
  final Map<String, dynamic> patient = Get.arguments;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController examinedByController = TextEditingController();
  final TextEditingController referredByController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController impressionCommentController = TextEditingController();

  final RxString selectedCountryCode = RxString('');
  final RxString selectedGender = RxString('');
  final RxString selectedStudy = RxString('');

  final RxBool isLoading = false.obs;

  // Image variables
  final List<File?> images = List.generate(4, (index) => null);
  final List<String> imageUrls = [];
  final List<TextEditingController> imageNameControllers = List.generate(4, (index) => TextEditingController());

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    nameController.text = patient['name'];
    ageController.text = patient['age'];
    selectedGender.value = patient['gender'];
    selectedCountryCode.value = patient['countryCode'];
    phoneNumberController.text = patient['phoneNumber'];
    selectedStudy.value = patient['study'];
    examinedByController.text = patient['examinedBy'];
    referredByController.text = patient['referredBy'];
    locationController.text = patient['location'];
    impressionCommentController.text = patient['impressionComment'];

    // Populate image URLs and image names
    imageUrls.addAll(patient['imageUrls']);
    List<String> imageNames = List<String>.from(patient['imageNames']);
    for (int i = 0; i < imageNames.length; i++) {
      imageNameControllers[i].text = imageNames[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey[100],
        elevation: 0,
        title: Text(
          'Edit Patient',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[100]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(
              () => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField('Patient Full Name', nameController),
                SizedBox(height: 16),
                _buildTextField('Age', ageController, inputType: TextInputType.number),
                SizedBox(height: 16),
                _buildDropdown('Gender', selectedGender, ['Male', 'Female', 'Other']),
                SizedBox(height: 16),
                Row(
                  children: [
                    Obx(
                          () => CountryCodePicker(
                        backgroundColor: Colors.white,
                        onChanged: (country) {
                          selectedCountryCode.value = country.dialCode!;
                        },
                        initialSelection: selectedCountryCode.value,
                        favorite: ['+91'],
                      ),
                    ),
                    Expanded(
                      child: _buildTextField('Enter Mobile Number', phoneNumberController,
                          inputType: TextInputType.phone, maxLength: 10),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildDropdown('Study', selectedStudy, [
                  'VDO-Practoscope',
                  'VDO-Oralscope',
                  'Otoscope',
                  'Rhinoscope',
                ]),
                SizedBox(height: 16),
                _buildTextField('Examined By', examinedByController),
                SizedBox(height: 16),
                _buildTextField('Referred By', referredByController),
                SizedBox(height: 16),
                _buildTextField('Location', locationController),
                SizedBox(height: 16),
                _buildTextField('Impression', impressionCommentController),
                SizedBox(height: 16),

                // Image Grid
                _buildImageGrid(),

                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading.value ? null : _onUpdatePatient,
                  child: isLoading.value
                      ? Image.asset(
                    'assets/icons/loading2.gif',
                    height: 24,
                  )
                      : Text(
                    'Update Patient',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text, int? maxLength, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, RxString selectedValue, List<String> items) {
    return DropdownButtonFormField<String>(
      value: selectedValue.value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: (value) {
        selectedValue.value = value!;
      },
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: images[index] != null
                    ? Image.file(images[index]!, fit: BoxFit.cover)
                    : imageUrls.isNotEmpty && index < imageUrls.length
                    ? Image.network(imageUrls[index], fit: BoxFit.cover)
                    : Icon(Icons.add_a_photo, color: Colors.black45),
              ),
            ),
            SizedBox(height: 8),
            _buildTextField('Image Name', imageNameControllers[index]),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images[index] = File(pickedFile.path);
      });
    }
  }

  Future<void> _onUpdatePatient() async {
    isLoading.value = true;

    try {
      // List to hold the updated URLs of uploaded images
      List<String> updatedImageUrls = [];

      for (int i = 0; i < images.length; i++) {
        if (images[i] != null) {
          // Upload image and get the URL
          String imageUrl = await _uploadImageToFirebase(images[i]!, imageNameControllers[i].text);
          updatedImageUrls.add(imageUrl);
        } else if (imageUrls.isNotEmpty && i < imageUrls.length) {
          updatedImageUrls.add(imageUrls[i]);
        }
      }

      // Collect updated patient details
      Map<String, dynamic> updatedPatientData = {
        'name': nameController.text,
        'age': ageController.text,
        'gender': selectedGender.value,
        'countryCode': selectedCountryCode.value,
        'phoneNumber': phoneNumberController.text,
        'study': selectedStudy.value,
        'examinedBy': examinedByController.text,
        'referredBy': referredByController.text,
        'location': locationController.text,
        'impressionComment': impressionCommentController.text,
        'imageUrls': updatedImageUrls,
        'imageNames': imageNameControllers.map((controller) => controller.text).toList(),
      };

      // Update patient details in Firebase
      await patientController.updatePatient(patient['uhid'], updatedPatientData);

      Get.back();
    } catch (e) {
      print('Error updating patient: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile, String imageName) async {
    String fileName = imageName.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : imageName;
    Reference storageRef = FirebaseStorage.instance.ref().child('patients/images/$fileName.jpg');

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
