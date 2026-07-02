import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_config.dart';
import '../../constants/app_durations.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../navigation/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../services/analytics/analytics_service.dart';
import '../../utils/snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/price_summary.dart';

/// Selectable (fake) payment methods.
enum _Payment {
  card('Credit / Debit Card', Icons.credit_card_rounded),
  paypal('PayPal', Icons.account_balance_wallet_rounded),
  cod('Cash on Delivery', Icons.payments_rounded);

  const _Payment(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Checkout: shipping address (fake, prefilled), payment method, promo code,
/// order summary and Place Order.
///
/// Placing an order records it in [OrdersProvider], clears the [CartProvider]
/// and routes to the order-success screen. All data is local; the "network"
/// step is a short simulated delay so the loading state is exercised.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _promoController = TextEditingController();

  _Payment _payment = _Payment.card;
  double _discountRate = 0; // Fraction off the subtotal from an applied promo.
  String? _appliedCode;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    context.read<AnalyticsService>().logEvent(
      AnalyticsEvents.beginCheckout,
      params: {'item_count': cart.totalQuantity, 'total': cart.total},
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    // Guard: nothing to check out (e.g. deep link with an empty cart).
    if (cart.isEmpty && !_placing) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.checkout)),
        body: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: AppStrings.emptyCartTitle,
          message: AppStrings.emptyCartMessage,
          actionLabel: AppStrings.continueShopping,
          onAction: () => context.goNamed(AppRoutes.nHome),
        ),
      );
    }

    final discount = cart.subtotal * _discountRate;
    final total = cart.total - discount;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.checkout)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          _ShippingCard(),
          Gaps.h16,
          _sectionTitle(context, AppStrings.paymentMethod),
          Gaps.h8,
          _PaymentSelector(
            selected: _payment,
            onChanged: (p) => setState(() => _payment = p),
          ),
          Gaps.h16,
          _sectionTitle(context, AppStrings.promoCode),
          Gaps.h8,
          _PromoField(
            controller: _promoController,
            appliedCode: _appliedCode,
            onApply: _applyPromo,
          ),
          Gaps.h24,
          _sectionTitle(context, AppStrings.orderSummary),
          Gaps.h8,
          PriceSummary.standard(
            subtotal: cart.subtotal,
            tax: cart.tax,
            shipping: cart.shipping,
            total: total,
            discount: discount,
          ),
          Gaps.h24,
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: FilledButton(
            onPressed: _placing ? null : () => _placeOrder(cart, total),
            child: _placing
                ? const SizedBox(
                    height: AppSizes.iconMd,
                    width: AppSizes.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(AppStrings.placeOrder),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      );

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    final rate = AppConfig.promoCodes[code];
    if (rate == null) {
      setState(() {
        _discountRate = 0;
        _appliedCode = null;
      });
      AppSnackbar.error(context, AppStrings.promoInvalid);
      return;
    }
    setState(() {
      _discountRate = rate;
      _appliedCode = code;
    });
    AppSnackbar.success(context, AppStrings.promoApplied);
  }

  Future<void> _placeOrder(CartProvider cart, double total) async {
    setState(() => _placing = true);
    // Simulate a brief payment/network round-trip.
    await Future<void>.delayed(AppDurations.fakeNetwork);
    if (!mounted) return;

    final orders = context.read<OrdersProvider>();
    final order = orders.placeOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      tax: cart.tax,
      shipping: cart.shipping,
      total: total,
      paymentMethod: _payment.label,
      placedAt: DateTime.now(),
    );
    cart.clear();

    if (!mounted) return;
    context.pushReplacementNamed(AppRoutes.nOrderSuccess, extra: order);
  }
}

/// Fake, prefilled shipping address card derived from the signed-in user.
class _ShippingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AuthProvider>().user;
    final name = user?.name ?? 'Nova Shopper';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: theme.colorScheme.primary),
            Gaps.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.shippingAddress,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                  Gaps.h4,
                  Text(name,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text('221B Demo Street, Suite 4\nNova City, NC 10101',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  AppSnackbar.info(context, 'Address editing is disabled in the demo.'),
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({required this.selected, required this.onChanged});

  final _Payment selected;
  final ValueChanged<_Payment> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RadioGroup<_Payment>(
        groupValue: selected,
        onChanged: (v) => onChanged(v!),
        child: Column(
          children: [
            for (final p in _Payment.values)
              RadioListTile<_Payment>(
                value: p,
                title: Text(p.label),
                secondary: Icon(p.icon),
                dense: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _PromoField extends StatelessWidget {
  const _PromoField({
    required this.controller,
    required this.appliedCode,
    required this.onApply,
  });

  final TextEditingController controller;
  final String? appliedCode;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. NOVA10',
              prefixIcon: const Icon(Icons.local_offer_outlined),
              helperText: appliedCode == null ? null : 'Applied: $appliedCode',
            ),
          ),
        ),
        Gaps.w12,
        SizedBox(
          height: AppSizes.inputHeight,
          child: FilledButton.tonal(
            // Override the theme's full-width minimum so the button sizes to
            // its label inside this Row (a bare height-only SizedBox would
            // otherwise inherit an infinite-width minimum and break layout).
            style: FilledButton.styleFrom(
              minimumSize: const Size(64, AppSizes.inputHeight),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            ),
            onPressed: onApply,
            child: const Text(AppStrings.applyPromo),
          ),
        ),
      ],
    );
  }
}
