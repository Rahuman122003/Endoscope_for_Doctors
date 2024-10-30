import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  final Map<String, dynamic> profile;

  ProfileDetailScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('Profile Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Colors.blueGrey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Info Section
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfo('Doctor\'s Full Name:', profile['fullName']),
                    _buildProfileInfo('Hospital Name:', profile['hospitalName']),
                    _buildProfileInfo('Email:', profile['email']),
                    _buildProfileInfo('Hospital Address:', profile['hospitalAddress']),
                    _buildProfileInfo('Contact Number:', profile['contactNumber']),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Logo Section
              if (profile['logoUrl'] != null && profile['logoUrl'].isNotEmpty)
                _buildImageSection(
                  title: 'Hospital Logo',
                  imageUrl: profile['logoUrl'],
                  screenWidth: screenWidth,
                ),

              SizedBox(height: 20),

              // Signature Section
              if (profile['signatureUrl'] != null && profile['signatureUrl'].isNotEmpty)
                _buildImageSection(
                  title: 'Doctor\'s Signature',
                  imageUrl: profile['signatureUrl'],
                  screenWidth: screenWidth,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for profile info display
  Widget _buildProfileInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey[600],
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to display images with error and loading handling
  Widget _buildImageSection({
    required String title,
    required String imageUrl,
    required double screenWidth,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey[800],
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: screenWidth * 0.4,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 100, color: Colors.blueGrey[200]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
