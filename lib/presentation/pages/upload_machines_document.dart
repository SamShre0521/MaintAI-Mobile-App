import 'package:file_picker/file_picker.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/storage/tokenStorage.dart';

class UploadMachinePage extends StatefulWidget {
  const UploadMachinePage({super.key});

  @override
  State<UploadMachinePage> createState() => _UploadMachinePageState();
}

class _UploadMachinePageState extends State<UploadMachinePage> {
  final machineNameController = TextEditingController();
  final specificationsController = TextEditingController();

  PlatformFile? selectedFile;
  bool isLoading = false;

  @override
  void dispose() {
    machineNameController.dispose();
    specificationsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'csv', 'xls', 'xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadMachine() async {
    final machineName = machineNameController.text.trim();
    final specifications = specificationsController.text.trim();

    if (machineName.isEmpty || specifications.isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter machine name, specifications and file'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final tokenStorage = TokenStorage();
      final apiClient = ApiClient(tokenStorage);

      final filePath = selectedFile!.path!;

      final formData = FormData.fromMap({
        'machineName': machineName,
        'specifications': specifications,
        'files': await MultipartFile.fromFile(
          filePath,
          filename: selectedFile!.name,
        ),
      });

      final response = await apiClient.dio.post(
        '/machines',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Machine uploaded successfully')),
      );

      machineNameController.clear();
      specificationsController.clear();

      setState(() {
        selectedFile = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F1),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF8F6F1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Upload Machine Data',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input(
            label: 'Machine Name',
            hint: 'Hydraulic Press',
            controller: machineNameController,
          ),
          const SizedBox(height: 16),
          _input(
            label: 'Specifications',
            hint: '200 Ton Press',
            controller: specificationsController,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE4DCC8)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFFF7ED),
                    child: Icon(
                      Icons.upload_file_rounded,
                      color: Color(0xFFF97316),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      selectedFile == null
                          ? 'Choose machine manual/file'
                          : selectedFile!.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _uploadMachine,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_rounded),
              label: Text(isLoading ? 'Uploading...' : 'Upload Machine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1C84B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFF1C84B)),
            ),
          ),
        ),
      ],
    );
  }
}
