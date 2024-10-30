import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controllers/patientController.dart';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final PatientController patientController = Get.put(PatientController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController examinedByController = TextEditingController();
  final TextEditingController referredByController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController impressionCommentController =
      TextEditingController();

  final RxString selectedCountryCode = "+91".obs;
  final RxString selectedGender = 'Male'.obs;
  final RxString selectedStudy = 'VDO-Practoscope'.obs;

  final RxBool isLoading = false.obs;

  // Image variables
  final List<File?> images = List.generate(4, (index) => null);
  final List<String> imageNames = List.generate(4, (index) => '');
  final List<TextEditingController> imageNameControllers =
      List.generate(4, (index) => TextEditingController());

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blueGrey[100],
          elevation: 0,
          title: Text(
            'Add Patient',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 18,
            ),
          ),
        ),
        body: Stack(children: [
          Container(
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
                    _buildTextField('Age', ageController,
                        inputType: TextInputType.number),
                    SizedBox(height: 16),
                    _buildDropdown(
                        'Gender', selectedGender, ['Male', 'Female', 'Other']),
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
                          child: _buildTextField(
                              'Enter Mobile Number', phoneNumberController,
                              inputType: TextInputType.phone, maxLength: 10),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDate != null) {
                          // Format the selected date and save it in the text controller
                          String formattedDate =
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                          locationController.text = formattedDate;
                        }
                      },
                      child: IgnorePointer(
                        child:
                            _buildTextField('Select Date', locationController),
                      ),
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
                    TextField(
                      controller: impressionCommentController,
                      minLines: 1,
                      // Starts with 1 line
                      maxLines: 200,
                      // Allows the box to grow up to 200 lines
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[800],
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Impression',
                        labelStyle: TextStyle(
                          color: Colors.blueGrey[600],
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey[300]!,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey[600]!,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

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
                      onPressed: isLoading.value ? null : _onAddPatient,
                      child: Text(
                        'Add Patient',
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

          // Loading overlay
          if (isLoading.value)
            Center(
                child: Container(
              color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Patient adding... this may take a few minutes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ))
        ]));
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text,
      int? maxLength,
      Function(String)? onChanged}) {
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

  Widget _buildDropdown(
      String label, RxString selectedValue, List<String> items) {
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
                    : Icon(Icons.add_a_photo, color: Colors.black45),
              ),
            ),
            SizedBox(height: 8),
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

  Future<void> _onAddPatient() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by clicking outside
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading GIF or Circular Progress Indicator
                isLoading.value
                    ? CircularProgressIndicator() // Show CircularProgressIndicator during loading
                    : Image.asset(
                  'assets/icons/pdf.gif', // Replace with your loading GIF asset path
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 16),
                Text(
                  "Please wait, the patient is being added. This may take a few seconds.",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    isLoading.value = true; // Show loading indicator

    try {
      List<String> imageUrls = [];

      // Upload images to Firebase
      for (int i = 0; i < images.length; i++) {
        if (images[i] != null) {
          String imageUrl = await _uploadImageToFirebase(
              images[i]!, imageNameControllers[i].text);
          imageUrls.add(imageUrl);
        }
      }

      // Prepare patient data
      final patientData = {
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
        'imageNames':
        imageNameControllers.map((controller) => controller.text).toList(),
        'imageUrls': imageUrls,
      };

      // Add patient data to Firebase
      await patientController.addPatient(patientData);

      Get.back(); // Close the dialog
      Get.snackbar('Success', 'Patient added successfully. Go Back And See');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add patient: $e');
    } finally {
      isLoading.value = false; // Hide loading indicator after operation completes
    }
  }


  Future<String> _uploadImageToFirebase(File image, String imageName) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}_$imageName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }
}
