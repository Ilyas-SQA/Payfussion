// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../core/constants/image_url.dart';
// import '../../data/models/Transactions_Modals/transaction_modal.dart';
//
//
// class TransactionListWidget extends StatefulWidget {
//   const TransactionListWidget({Key? key}) : super(key: key);
//
//   @override
//   State<TransactionListWidget> createState() => _TransactionListWidgetState();
// }
//
// class _TransactionListWidgetState extends State<TransactionListWidget> {
//   @override
//   void initState() {
//     super.initState();
//     // Load transactions when widget is initialized
//     context.read<TransactionBloc>().add(const TransactionLoadRequested());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Container(
//       height: 392.h,
//       width: 405.w,
//       decoration: BoxDecoration(
//         color: theme.primaryColor,
//         borderRadius: BorderRadius.circular(10.r),
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: const Color(0xff8CB7FF).withOpacity(0.6),
//             blurRadius: 20,
//             offset: const Offset(0, 7),
//           ),
//         ],
//       ),
//       child: BlocBuilder<TransactionBloc, TransactionState>(
//         builder: (context, state) {
//           return Column(
//             children: <Widget>[
//               TransactionItemHeader(
//                 heading: 'Today',
//                 showTrailingButton: true,
//                 onRefresh: () {
//                   context.read<TransactionBloc>().add(const TransactionRefreshRequested());
//                 },
//               ),
//               SizedBox(height: 20.h),
//               Expanded(
//                 child: _buildTransactionList(state),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTransactionList(TransactionState state) {
//     switch (state.status) {
//       case TransactionStatus.loading:
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//
//       case TransactionStatus.failure:
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 48.sp,
//                 color: Colors.red,
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 'Failed to load transactions',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   color: Colors.red,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               TextButton(
//                 onPressed: () {
//                   context.read<TransactionBloc>().add(const TransactionLoadRequested());
//                 },
//                 child: const Text('Try Again'),
//               ),
//             ],
//           ),
//         );
//
//       case TransactionStatus.success:
//         final todayTransactions = state.todayTransactions;
//
//         if (todayTransactions.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.receipt_long_outlined,
//                   size: 48.sp,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: 16.h),
//                 Text(
//                   'No transactions today',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return ListView.separated(
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           itemCount: todayTransactions.length,
//           separatorBuilder: (context, index) => SizedBox(height: 10.h),
//           itemBuilder: (context, index) {
//             final transaction = todayTransactions[index];
//             return TransactionItem(
//               iconPath: _getTransactionIcon(transaction),
//               heading: _getTransactionTitle(transaction),
//               transactionId: transaction.id.isEmpty ? 'Processing...' : transaction.id.substring(0, 10),
//               moneyValue: transaction.amount.toStringAsFixed(2),
//               status: _formatStatus(transaction.status),
//               date: DateFormat('dd/MM/yyyy').format(transaction.createdAt),
//               time: DateFormat('hh:mm a').format(transaction.createdAt),
//             );
//           },
//         );
//
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   String _getTransactionIcon(TransactionModel transaction) {
//     // You can customize this based on your transaction types
//     if (transaction.recipientName.toLowerCase().contains('exchange') ||
//         transaction.note?.toLowerCase().contains('exchange') == true) {
//       return TImageUrl.iconConversionTransaction;
//     } else if (transaction.amount > 0) {
//       return TImageUrl.iconCreditCardTransaction; // Cash-In
//     } else {
//       return TImageUrl.iconConversionTransaction; // Cash-Out
//     }
//   }
//
//   String _getTransactionTitle(TransactionModel transaction) {
//     // You can customize this based on your business logic
//     if (transaction.recipientName.toLowerCase().contains('exchange')) {
//       return 'Currency Exchange';
//     } else if (transaction.amount > 0) {
//       return 'Payment to ${transaction.recipientName}';
//     } else {
//       return 'Cash-Out';
//     }
//   }
//
//   String _formatStatus(String status) {
//     switch (status.toLowerCase()) {
//       case 'success':
//         return 'Completed';
//       case 'pending':
//         return 'Pending';
//       case 'failed':
//         return 'Failed';
//       default:
//         return status.substring(0, 1).toUpperCase() + status.substring(1);
//     }
//   }
// }
//
// class TransactionItemHeader extends StatelessWidget {
//   final String heading;
//   final bool showTrailingButton;
//   final VoidCallback? onRefresh;
//
//   const TransactionItemHeader({
//     Key? key,
//     required this.heading,
//     this.showTrailingButton = false,
//     this.onRefresh,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             heading,
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           if (showTrailingButton)
//             IconButton(
//               onPressed: onRefresh,
//               icon: const Icon(Icons.refresh),
//               iconSize: 20.sp,
//             ),
//         ],
//       ),
//     );
//   }
// }