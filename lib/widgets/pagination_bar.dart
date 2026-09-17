import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;

  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSizeChanged;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    required this.onPageChanged,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment:
          WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 8,
      children: [
        IconButton(
          onPressed: page > 1
              ? () => onPageChanged(1)
              : null,
          icon: const Icon(
            Icons.first_page,
          ),
        ),

        IconButton(
          onPressed: page > 1
              ? () =>
                  onPageChanged(page - 1)
              : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),

        Text(
          'Страница $page из $totalPages · Всего: $total',
        ),

        IconButton(
          onPressed: page < totalPages
              ? () =>
                  onPageChanged(page + 1)
              : null,
          icon: const Icon(
            Icons.chevron_right,
          ),
        ),

        IconButton(
          onPressed: page < totalPages
              ? () => onPageChanged(
                    totalPages,
                  )
              : null,
          icon: const Icon(
            Icons.last_page,
          ),
        ),

        const SizedBox(width: 8),

        const Text(
          'На странице:',
        ),

        DropdownButton<int>(
          value: size,
          items: const [
            10,
            25,
            50,
          ]
              .map(
                (value) =>
                    DropdownMenuItem<int>(
                  value: value,
                  child:
                      Text('$value'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onSizeChanged(value);
            }
          },
        ),
      ],
    );
  }
}