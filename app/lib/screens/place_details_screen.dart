import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:scanning_world/data/remote/providers/places_provider.dart';
import 'package:scanning_world/services/url_service.dart';
import 'package:scanning_world/theme/theme.dart';
import 'package:scanning_world/widgets/common/custom_progress_indicator.dart';
import 'package:scanning_world/widgets/common/platform_input_group.dart';
import 'package:scanning_world/widgets/common/platfrom_input.dart';
import 'package:scanning_world/widgets/home/map/pick_map_bottom_sheet.dart';
import '../data/remote/models/user/place.dart';
import '../data/remote/providers/auth_provider.dart';
import '../widgets/common/cached_placeholder_image.dart';
import '../widgets/common/error_dialog.dart';
import '../widgets/place_details/review_row.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailsScreen({Key? key, required this.placeId}) : super(key: key);

  static const routeName = '/place-details';

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Future<void> _openMapsSheet(
      context, double lat, double lng, String title) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      showPlatformModalSheet(
        context: context,
        builder: (BuildContext context) {
          return PickMapBottomSheet(
              availableMaps: availableMaps, title: title, lat: lat, lng: lng);
        },
      );
    } catch (e) {
      showPlatformDialog(
          context: context, builder: (c) => ErrorDialog(message: e.toString()));
    }
  }

  int rating = 5;
  String review = '';
  var _isLoading = false;

  Future<void> _ratePlace() async {

    try {
      await context
          .read<PlacesProvider>()
          .ratePlace(widget.placeId, rating, review);
      if(!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      showPlatformDialog(
          context: context, builder: (c) => ErrorDialog(message: e.toString()));
    }
  }

  Future<void> _openRatePlaceSheet(context, Place place) async {
    try {
      showPlatformModalSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Oceń miejsce',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RatingBar.builder(
                      initialRating: rating.toDouble(),
                      glowColor: Colors.amber,
                      minRating: 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (r) {
                        setState(() {
                          rating = r.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    PlatformInputGroup(children: [
                      PlatformInput(
                          minLines: 1,
                          maxLines: 3,
                          maxLength: 100,
                          onChanged: (value) {
                            setState(() {
                              review = value;
                            });
                          },
                          hintText: 'Komentarz',
                          prefixIcon: context.platformIcon(
                              material: Icons.chat_outlined,
                              cupertino: CupertinoIcons.chat_bubble_text)),
                    ]),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: PlatformElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          setModalState(() {
                            _isLoading = true;
                          });
                          await _ratePlace();
                          setModalState(() {
                            _isLoading = false;
                          });
                        },
                        child: _isLoading
                            ? const CustomProgressIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Oceń miejsce',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    context.platformIcons.star,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        },
      );
    } catch (e) {
      showPlatformDialog(
          context: context, builder: (c) => ErrorDialog(message: e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    //get screen height
    final screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final Place? place =
        context.watch<PlacesProvider>().getPlaceById(widget.placeId);
    if (place != null) {
      return PlatformScaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    CachedPlaceholderImage(
                      imageUrl: place.imageUri,
                      width: double.infinity,
                      height: screenHeight * 0.4,
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      child: PlatformIconButton(
                        color: Colors.white30,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          context.platformIcons.back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                     if (place.averageRating != 0) Positioned(
                        bottom: 40,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(59),
                          ),
                          child: Row(
                            children: [
                              Text(
                                place.averageRating.toStringAsFixed(1),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Icon(
                                context.platformIcon(
                                    material: Icons.star,
                                    cupertino: CupertinoIcons.star_fill),
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -24.0, 0.0),
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${place.name} - ${place.points}pkt",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Text(
                            place.locationLatLng,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                            final bool isPlaceScanned =
                                authProvider.user?.isPlaceScanned(place.id) ??
                                    false;
                            return Row(
                              children: [
                                Icon(
                                    context.platformIcon(
                                        material: isPlaceScanned
                                            ? Icons.check_circle
                                            : Icons.dangerous,
                                        cupertino: isPlaceScanned
                                            ? CupertinoIcons
                                                .check_mark_circled_solid
                                            : CupertinoIcons
                                                .clear_thick_circled),
                                    size: 15,
                                    color: isPlaceScanned
                                        ? Colors.green
                                        : Colors.redAccent),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  isPlaceScanned
                                      ? 'Odwiedzone'
                                      : 'Nieodwiedzone',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: isPlaceScanned
                                          ? Colors.green
                                          : Colors.redAccent),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        place.description,
                        style: const TextStyle(fontSize: 15),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        height: screenHeight * 0.3,
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(place.location.lat.toDouble(),
                                place.location.lng.toDouble()),
                            zoom: 14.0,
                            minZoom: 8.0,
                          ),
                          nonRotatedChildren: [
                            AttributionWidget(
                              attributionBuilder: (context) {
                                return Container(
                                    padding: const EdgeInsets.all(2),
                                    color: Colors.white60,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'flutter_map | ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => UrlService.launchLink(
                                              'https://www.openstreetmap.org/copyright'),
                                          child: const Text(
                                            ' © OpenStreetMap contributors',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ));
                              },
                            ),
                          ],
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(place.location.lat.toDouble(),
                                      place.location.lng.toDouble()),
                                  width: 80,
                                  height: 80,
                                  builder: (context) => Icon(
                                      context.platformIcons.locationSolid,
                                      size: 32,
                                      color: primary[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: PlatformElevatedButton(
                          child: const Text(
                            'Nawiguj',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            _openMapsSheet(
                                context,
                                place.location.lat.toDouble(),
                                place.location.lng.toDouble(),
                                place.name);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: primary[700]!, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: PlatformTextButton(
                          material: (_, __) => MaterialTextButtonData(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                          ),
                          color: Colors.white,
                          onPressed: () {
                            _openRatePlaceSheet(context, place);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Oceń miejsce',
                                style: TextStyle(color: primary[700]!),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Icon(
                                context.platformIcons.star,
                                color: primary[700],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      const Text(
                        'Oceny',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      place.reviews.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(top: 12),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: place.reviews.length,
                              itemBuilder: (context, index) => ReviewRow(
                                review: place.reviews[index],
                              ),
                            )
                          : Text(
                              'To miejsce nie posiada żadnych ocen',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ));
    }
    return const Center(child: CircularProgressIndicator());
  }
}
