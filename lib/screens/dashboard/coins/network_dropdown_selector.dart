import 'package:flutter/material.dart';
import 'package:legit_cards/data/repository/app_repository.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';

class NetworkDropdownSelector extends StatefulWidget {
  final Function(String) onSelected;

  const NetworkDropdownSelector({super.key, required this.onSelected});

  @override
  State<NetworkDropdownSelector> createState() =>
      _NetworkDropdownSelectorState();
}

class _NetworkDropdownSelectorState extends State<NetworkDropdownSelector> {
  final List<String> networks = [
    "MTN Nigeria",
    "Glo Nigeria",
    "Airtel Nigeria"
  ];
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => _buildBottomSheet(),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: selected ?? "Select Network",
                  color: selected == null
                      ? Colors.grey.withOpacity(0.5)
                      : context.blackWhite,
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          height: 5,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        const SizedBox(height: 15),
        ...networks.map((net) => ListTile(
              title: CustomText(text: net),
              onTap: () {
                setState(() => selected = net);
                widget.onSelected(net);
                Navigator.pop(context);
              },
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}
