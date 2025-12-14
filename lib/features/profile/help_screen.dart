import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _sendSupportEmail() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;
    final String os = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'nhoth9518@ut.edu.vn',
      query: _encodeQueryParameters(<String, String>{
        'subject': '[Today’s Eats] Hỗ trợ',
        'body': '\n\n---\nPhiên bản app: $version ($buildNumber)\nThiết bị: $os\nMô tả vấn đề: '
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Không thể mở ứng dụng gửi mail';
      }
    } catch (e) {
      debugPrint("Error sending email: $e");
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chúng tôi có thể giúp gì cho bạn?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nếu bạn gặp sự cố hoặc có câu hỏi nào,\nhãy liên hệ đội ngũ hỗ trợ.',
                style: TextStyle(color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _sendSupportEmail,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Gửi email hỗ trợ', style: TextStyle(fontSize: 16)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
