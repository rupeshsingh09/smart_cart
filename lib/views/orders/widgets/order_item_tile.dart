import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order_model.dart';
import '../../../utils/constants.dart';

class OrderItemTile extends StatelessWidget {
  final OrderModel order;

  const OrderItemTile({super.key, required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'paid': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'failed': return AppColors.error;
      case 'confirmed': return AppColors.primary;
      case 'shipped': return AppColors.primary;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'paid': return Icons.verified_outlined;
      case 'pending': return Icons.schedule;
      case 'failed': return Icons.error_outline;
      case 'confirmed': return Icons.check_circle_outline;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'delivered': return Icons.done_all;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 2))
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _statusColor(order.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(_statusIcon(order.status), color: _statusColor(order.status)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text('₹${order.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                      style: TextStyle(
                          fontSize: 12, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 6),
                  Text(
                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _statusColor(order.status).withValues(alpha: 0.3))),
                child: Text(order.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _statusColor(order.status),
                        letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
        trailing: const SizedBox.shrink(),
        children: [
          const Divider(height: 1),
          ...order.items.map((item) => ListTile(
                dense: true,
                title:
                    Text(item.product.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                    '₹${item.product.price.toStringAsFixed(0)} × ${item.quantity}',
                    style: const TextStyle(fontSize: 12)),
                trailing: Text('₹${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
