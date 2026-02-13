import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/rental_module/chat/screens/taxi_chat_screen.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/features/rental_module/trips/screens/trip_details_screen.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;

  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Bounce animation for logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceOut,
      ),
    );

    // Fade + slide-up animation for text
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Connectivity listener
    bool firstTime = true;
    _onConnectivityChanged =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
          bool isConnected = result.contains(ConnectivityResult.wifi) ||
              result.contains(ConnectivityResult.mobile);

          if (!firstTime) {
            isConnected
                ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar()
                : const SizedBox();

            ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(
                backgroundColor: isConnected ? Colors.green : Colors.red,
                duration: Duration(seconds: isConnected ? 3 : 6000),
                content: Text(
                  isConnected ? 'connected'.tr : 'no_connection'.tr,
                  textAlign: TextAlign.center,
                ),
              ),
            );

            if (isConnected) {
              _route();
            }
          }
          firstTime = false;
        });

    // Initialize splash data and route
    Get.find<SplashController>().initSharedData();
    _route();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) async {
      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = _getMinimumVersion();
          bool isMaintenanceMode =
          Get.find<SplashController>().configModel!.maintenanceMode!;
          bool needsUpdate = AppConstants.appVersion < minimumVersion!;

          if (needsUpdate || isMaintenanceMode) {
            Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
          } else {
            if (widget.body != null) {
              await _handleNotificationRouting(widget.body);
            } else {
              await _handleDefaultRouting();
            }
          }
        });
      }
    });
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>()
          .configModel!
          .appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>()
          .configModel!
          .appMinimumVersionIos;
    }
    return 0;
  }

  Future<void> _handleNotificationRouting(NotificationBodyModel? notificationBody) async {
    final notificationType = notificationBody?.notificationType;

    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () {
        if (Get.find<AuthController>().getModuleType() == 'rental') {
          Get.to(() => TripDetailsScreen(
              tripId: notificationBody!.orderId!, fromNotification: true));
        } else {
          Get.toNamed(RouteHelper.getOrderDetailsRoute(
              notificationBody?.orderId,
              fromNotification: true));
        }
      },
      NotificationType.advertisement: () => Get.toNamed(
          RouteHelper.getAdvertisementDetailsScreen(
              advertisementId: notificationBody?.advertisementId,
              fromNotification: true)),
      NotificationType.block: () =>
          Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.unblock: () =>
          Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.withdraw: () =>
          Get.to(const DashboardScreen(pageIndex: 3)),
      NotificationType.campaign: () => Get.toNamed(
          RouteHelper.getCampaignDetailsRoute(
              id: notificationBody?.campaignId,
              fromNotification: true)),
      NotificationType.message: () {
        if (Get.find<AuthController>().getModuleType() == 'rental') {
          Get.to(() => TaxiChatScreen(
              notificationBody: notificationBody,
              conversationId: notificationBody?.conversationId,
              fromNotification: true));
        } else {
          Get.toNamed(RouteHelper.getChatRoute(
              notificationBody: notificationBody,
              conversationId: notificationBody?.conversationId,
              fromNotification: true));
        }
      },
      NotificationType.subscription: () =>
          Get.toNamed(RouteHelper.getMySubscriptionRoute(fromNotification: true)),
      NotificationType.product_approve: () =>
          Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
      NotificationType.product_rejected: () =>
          Get.toNamed(RouteHelper.getPendingItemRoute(fromNotification: true)),
      NotificationType.general: () =>
          Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    notificationActions[notificationType]?.call();
  }

  Future<void> _handleDefaultRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().updateToken();
      Get.find<AuthController>().getModuleType() == 'rental'
          ? await Get.find<TaxiProfileController>().getProfile()
          : await Get.find<ProfileController>().getProfile();
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      final bool showIntro = Get.find<SplashController>().showIntro();
      if (AppConstants.languages.length > 1 && showIntro) {
        Get.offNamed(RouteHelper.getLanguageRoute('splash'));
      } else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bounce logo
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(Images.logo, width: 200),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              // Fade + slide text
              SlideTransition(
                position: _textSlideAnimation,
                child: FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Text(
                    'suffix_name'.tr,
                    style: robotoMedium,
                    textAlign: TextAlign.center,
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
