import 'package:flutter/material.dart';

class ConnectStripeAccountScreen extends StatelessWidget {
  const ConnectStripeAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Stripe Account')),
      body: const Center(child: Text('Connect Stripe Account Screen')),
    );
  }
}
