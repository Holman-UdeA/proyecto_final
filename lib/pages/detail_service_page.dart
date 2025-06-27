import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailServicePage extends StatefulWidget {
  final QueryDocumentSnapshot service;

  const DetailServicePage(this.service, {super.key});

  @override
  State<DetailServicePage> createState() => _DetailServicePageState(service);
}

class _DetailServicePageState extends State<DetailServicePage> {
  final QueryDocumentSnapshot service;

  _DetailServicePageState(this.service);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
