import 'package:croppy/src/src.dart';
import 'package:flutter/material.dart';

class DefaultCupertinoCroppableImageController extends StatefulWidget {
  const DefaultCupertinoCroppableImageController({
    super.key,
    required this.builder,
    required this.imageProvider,
    this.initialData,
    this.postProcessFn,
    this.cropShapeFn,
    this.allowedAspectRatios,
    this.enabledTransformations,
    this.showLoadingIndicatorOnSubmit = false,
    this.showGestureHandlesOn = const [CropShapeType.aabb],
    this.overlayColor,
  });

  final ImageProvider imageProvider;
  final CroppableImageData? initialData;
  final CroppableImagePostProcessFn? postProcessFn;
  final CropShapeFn? cropShapeFn;
  final List<CropAspectRatio?>? allowedAspectRatios;
  final List<Transformation>? enabledTransformations;
  final bool showLoadingIndicatorOnSubmit;
  final List<CropShapeType> showGestureHandlesOn;
  final Color? overlayColor;

  final Widget Function(
    BuildContext context,
    CupertinoCroppableImageController controller,
  ) builder;

  @override
  State<DefaultCupertinoCroppableImageController> createState() =>
      _DefaultCupertinoCroppableImageControllerState();
}

class _DefaultCupertinoCroppableImageControllerState
    extends State<DefaultCupertinoCroppableImageController>
    with TickerProviderStateMixin {
  CupertinoCroppableImageController? _controller;

  @override
  void initState() {
    super.initState();
    _prepareController();
  }

  @override
  void didUpdateWidget(DefaultCupertinoCroppableImageController oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Commenting out needsControllerRebuild as it's not used for now.
    // bool needsControllerRebuild = false;

    if (widget.imageProvider != oldWidget.imageProvider ||
        widget.cropShapeFn != oldWidget.cropShapeFn) {
      // If fundamental properties change, we might need to re-initialize the controller fully.
      // This might involve disposing the old controller and calling _prepareController again.
      // For now, we assume these don't change while the cropper is active, or a full rebuild is handled elsewhere.
    }

    if (_controller != null && widget.overlayColor != oldWidget.overlayColor) {
      // Update the overlayColor in the controller's data.
      // The controller (ChangeNotifier) should notify its listeners when 'data' is set.
      _controller!.data = _controller!.data.copyWith(
        overlayColor: widget.overlayColor,
      );
    }
    
    // The following properties are final in CupertinoCroppableImageController and cannot be updated this way.
    // If they need to be dynamic, the controller's design would need to change.
    // For now, commenting out to fix lint errors and focus on overlayColor.
    // if (_controller != null) {
    //   if (widget.allowedAspectRatios != oldWidget.allowedAspectRatios) {
    //     // _controller!.allowedAspectRatios = widget.allowedAspectRatios; // This is final
    //   }
    //   if (widget.enabledTransformations != oldWidget.enabledTransformations) {
    //     // _controller!.enabledTransformations = widget.enabledTransformations ?? Transformation.values; // This is final
    //   }
    // }
  }

  Future<void> _prepareController() async {
    late final CroppableImageData initialData;

    if (widget.initialData != null) {
      initialData = CroppableImageData(
        imageSize: widget.initialData!.imageSize,
        cropRect: widget.initialData!.cropRect,
        cropShape: widget.initialData!.cropShape,
        baseTransformations: widget.initialData!.baseTransformations,
        imageTransform: widget.initialData!.imageTransform,
        currentImageTransform: widget.initialData!.currentImageTransform,
        overlayColor: widget.overlayColor,
      );
    } else {
      initialData = await CroppableImageData.fromImageProvider(
        widget.imageProvider,
        cropPathFn: widget.cropShapeFn ?? aabbCropShapeFn,
        overlayColor: widget.overlayColor,
      );
    }

    _controller = CupertinoCroppableImageController(
      vsync: this,
      imageProvider: widget.imageProvider,
      data: initialData,
      postProcessFn: widget.postProcessFn,
      cropShapeFn: widget.cropShapeFn ?? aabbCropShapeFn,
      allowedAspectRatios: widget.allowedAspectRatios,
      enabledTransformations:
          widget.enabledTransformations ?? Transformation.values,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return widget.builder(context, _controller!);
  }
}
