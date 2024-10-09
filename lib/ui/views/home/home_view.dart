import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:rideshare/ui/common/app_strings.dart';
import 'package:rideshare/ui/common/uihelper/text_helper.dart';
import 'package:rideshare/ui/common/uihelper/text_veiw_helper.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:rideshare/ui/common/app_colors.dart';
import 'package:rideshare/ui/common/ui_helpers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/apihelpers/apihelper.dart';
import '../../common/uihelper/button_helper.dart';
import '../../common/uihelper/snakbar_helper.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  String capital(String text, int index, bool isBold) {
    String bold = "";
    String notBold = "";

    for (int i = 0; i < text.length; i++) {
      if (i < index) {
        bold += text[i];
      }
      if (i >= index + 1) {
        notBold += text[i];
      }
    }

    if (isBold) {
      return bold;
    } else {
      return notBold;
    }
  }

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SlidingUpPanel(
          controller: viewModel.panelController,
          onPanelOpened: () => viewModel.panel(),
          onPanelClosed: () => viewModel.panel(),
          minHeight: 110,
          panel: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text_helper(
                      data: "Avaliable Routes",
                      font: openSans,
                      bold: true,
                      color: kcDarkGreyColor,
                      size: fontSize16,
                    ),
                    InkWell(
                      onTap: () => viewModel.updatefilter(),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: kcPrimaryColor),
                        child: Icon(viewModel.filter
                            ? Icons.filter_alt_rounded
                            : Icons.filter_alt_off_rounded),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                          width: screenWidth(context),
                          height: 35,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.filters.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  viewModel.cfilter = viewModel.filters[index];
                                  viewModel.notifyListeners();
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: viewModel.cfilter ==
                                            viewModel.filters[index]
                                        ? kcDarkGreyColor
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: text_helper(
                                      data: viewModel.filters[index],
                                      font: openSans,
                                      color: viewModel.cfilter ==
                                              viewModel.filters[index]
                                          ? white
                                          : kcDarkGreyColor,
                                      size: fontSize14,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )),
                      Expanded(
                        child: FutureBuilder(
                          future: ApiHelper.getservice(
                              viewModel.sharedpref.readString('number')),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data.toString() == '[]') {
                                return Center(
                                  child: text_helper(
                                      data: "No Data",
                                      font: openSans,
                                      color: kcDarkGreyColor,
                                      size: fontSize14),
                                );
                              } else {
                                return ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    if (snapshot.data[index]['number']['number']
                                            .toString() ==
                                        viewModel.sharedpref
                                            .readString('number')) {
                                      return const SizedBox.shrink();
                                    } else {
                                      if (viewModel.cfilter == "all") {
                                        return locfilter(context, viewModel,
                                            snapshot, index);
                                      } else if (viewModel.cfilter == "new") {
                                        DateTime dateFromString =
                                            DateTime.parse(snapshot.data[index]
                                                ['number']['datetime']);
                                        DateTime currentDate = DateTime.now()
                                            .subtract(
                                                const Duration(minutes: 30));
                                        int comparisonResult = dateFromString
                                            .compareTo(currentDate);
                                        if (comparisonResult >= 0) {
                                          return locfilter(context, viewModel,
                                              snapshot, index);
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      } else if (viewModel.cfilter ==
                                          "progress") {
                                        if (snapshot.data[index]['number']
                                                ['status'] ==
                                            "progress") {
                                          return locfilter(context, viewModel,
                                              snapshot, index);
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      } else if (viewModel.cfilter ==
                                          "completed") {
                                        if (snapshot.data[index]['number']
                                                ['status'] ==
                                            "completed") {
                                          return locfilter(context, viewModel,
                                              snapshot, index);
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }
                                  },
                                );
                              }
                            } else if (snapshot.hasError) {
                              return const Icon(
                                Icons.error,
                                color: kcDarkGreyColor,
                              );
                            } else {
                              return displaysimpleprogress(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          collapsed: Container(
            color: white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text_helper(
                          data: "Select Ride",
                          font: openSans,
                          bold: true,
                          color: kcDarkGreyColor,
                          size: fontSize12),
                      text_helper(
                          data: viewModel.distance == ""
                              ? ""
                              : viewModel.distance,
                          font: openSans,
                          bold: true,
                          color: kcDarkGreyColor,
                          size: fontSize12),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        selectionride('car', viewModel, context),
                        selectionride('bike', viewModel, context),
                      ],
                    ),
                    InkWell(
                      onTap: () => viewModel.booking(context),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kcDarkGreyColor),
                        child: text_helper(
                            data: viewModel.sharedpref.readString("cat") ==
                                    "rider"
                                ? "Book Now"
                                : "Post Now",
                            font: openSans,
                            bold: true,
                            color: white,
                            size: fontSize14),
                      ),
                    )
                  ],
                ),
                viewModel.prices.isEmpty
                    ? const SizedBox.shrink()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          text_helper(
                              data: "Prices",
                              font: openSans,
                              bold: true,
                              color: kcDarkGreyColor,
                              size: fontSize14),
                          SizedBox(
                            width: screenWidthCustom(context, 0.7),
                            height: 20,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: viewModel.prices
                                  .map((e) => InkWell(
                                        onTap: () {
                                          viewModel.selectedprice.text = e;
                                          viewModel.notifyListeners();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: text_helper(
                                              data: e,
                                              font: openSans,
                                              bold: viewModel
                                                      .selectedprice.text ==
                                                  e,
                                              color: kcDarkGreyColor,
                                              size: fontSize14),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          horizontalSpaceTiny,
                          InkWell(
                              onTap: () => showdialog(context, viewModel),
                              child: const Icon(
                                Icons.add,
                              ))
                        ],
                      )
              ],
            ),
          ),
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: viewModel.current,
                onMapCreated: (GoogleMapController controller) {
                  viewModel.controller = controller;
                },
                markers: viewModel.markers,
                polylines: Set<Polyline>.of(viewModel.polyines.values),
              ),
              Container(
                width: screenWidth(context),
                margin: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    text_helper(
                      data: "Welcome ${viewModel.sharedpref.readString("cat")}",
                      font: openSans,
                      bold: true,
                      color: white,
                      size: fontSize14,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: screenWidth(context),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenWidthCustom(context, 0.8),
                                child: text_view_helper(
                                  textcolor: kcDarkGreyColor,
                                  showicon: true,
                                  icon: const Icon(Icons.my_location_rounded),
                                  margin: const EdgeInsetsDirectional.all(0),
                                  padding: const EdgeInsetsDirectional.all(0),
                                  inputBorder: InputBorder.none,
                                  hint: "current location",
                                  controller: viewModel.currentloc,
                                  onchange: (query) {
                                    viewModel.search(query, "current");
                                  },
                                ),
                              ),
                              // InkWell(
                              //     onTap: () => viewModel.currentgo(context),
                              //     child: const Icon(
                              //         Icons.arrow_downward_outlined)),
                            ],
                          ),
                          if (viewModel.locationType == "current")
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: viewModel.searchResult.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    await viewModel.getPlaceById(
                                      viewModel.searchResult[index]["place_id"],
                                      context,
                                    );

                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.location_on_outlined,
                                    ),
                                    title: Text(
                                      capital(
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString(),
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString()
                                            .indexOf(","),
                                        true,
                                      ).toString().trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      capital(
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString(),
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString()
                                            .indexOf(","),
                                        false,
                                      ).toString().trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: screenWidth(context),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenWidthCustom(context, 0.8),
                                child: text_view_helper(
                                  textcolor: kcDarkGreyColor,
                                  showicon: true,
                                  icon: const Icon(
                                      Icons.not_listed_location_sharp),
                                  margin: const EdgeInsetsDirectional.all(0),
                                  padding: const EdgeInsetsDirectional.all(0),
                                  inputBorder: InputBorder.none,
                                  hint: "Where you want to go",
                                  controller: viewModel.loc,
                                  onchange: (query) {
                                    viewModel.search(query, "target");
                                  },
                                ),
                              ),
                              // InkWell(
                              //     onTap: () => viewModel.target(context),
                              //     child: const Icon(Icons.search)),
                            ],
                          ),
                          if (viewModel.locationType == "target")
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: viewModel.searchResult.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    print("taptap");
                                    await viewModel.getPlaceById(
                                      viewModel.searchResult[index]["place_id"],
                                      context,
                                    );

                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.location_on_outlined,
                                    ),
                                    title: Text(
                                      capital(
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString(),
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString()
                                            .indexOf(","),
                                        true,
                                      ).toString().trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      capital(
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString(),
                                        viewModel.searchResult[index]
                                                ["description"]
                                            .toString()
                                            .indexOf(","),
                                        false,
                                      ).toString().trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: viewModel.open
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        elevation: 0,
                        mini: true,
                        onPressed: () => profiledialog(context, viewModel),
                        backgroundColor: kcPrimaryColor,
                        child: const Icon(Icons.person),
                      ),
                      FloatingActionButton(
                        elevation: 0,
                        mini: true,
                        onPressed: () => viewModel.editprofile(),
                        backgroundColor: kcPrimaryColor,
                        child: const Icon(Icons.edit),
                      ),
                      FloatingActionButton(
                        elevation: 0,
                        mini: true,
                        onPressed: () => viewModel.chats(),
                        backgroundColor: kcPrimaryColor,
                        child: const Icon(Icons.chat),
                      ),
                      FloatingActionButton(
                        elevation: 0,
                        mini: true,
                        onPressed: () => viewModel.wallet(),
                        backgroundColor: kcPrimaryColor,
                        child: const Icon(Icons.wallet),
                      ),
                      verticalSpaceLarge,
                      verticalSpaceLarge
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      elevation: 0,
                      mini: true,
                      onPressed: () => viewModel.logout(),
                      backgroundColor: kcPrimaryColor,
                      child: const Icon(Icons.logout),
                    ),
                    FloatingActionButton(
                      elevation: 0,
                      mini: true,
                      onPressed: () => viewModel.zoom(),
                      backgroundColor: kcPrimaryColor,
                      child: const Icon(Icons.zoom_in_map),
                    ),
                    FloatingActionButton(
                      mini: true,
                      elevation: 0,
                      onPressed: () => viewModel.zoomout(),
                      backgroundColor: kcPrimaryColor,
                      child: const Icon(Icons.zoom_out_map),
                    ),
                    FloatingActionButton(
                      elevation: 0,
                      mini: true,
                      onPressed: () => viewModel.getLocation1(),
                      backgroundColor: kcPrimaryColor,
                      child: const Icon(Icons.my_location_sharp),
                    ),
                    verticalSpaceLarge,
                    verticalSpaceLarge
                  ],
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  void profiledialog(BuildContext context, HomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners for the dialog
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              text_helper(
                data: "Profile",
                font: raleway,
                color: kcDarkGreyColor,
                size: fontSize24, // Slightly larger font size for the title
                bold: true,
              ),
              const SizedBox(height: 16), // Spacing
              _profileDetail(Icons.person, "Name", "${viewModel.sharedpref.readString('fname')} ${viewModel.sharedpref.readString('lname')}"),
              _profileDetail(Icons.call, "Number", viewModel.sharedpref.readString('number')),
              _profileDetail(Icons.email, "Email", viewModel.sharedpref.readString('email')),
              _profileDetail(Icons.transgender, "Gender", viewModel.sharedpref.readString('gender')),
              _profileDetail(Icons.calendar_today, "DOB", viewModel.sharedpref.readString('dob')),
              if (viewModel.sharedpref.readString('cat') == "rider") ...[
                _profileDetail(Icons.bike_scooter, "Bike", viewModel.sharedpref.readString('bike')),
                _profileDetail(Icons.edit_document, "License No", viewModel.sharedpref.readString('lic')),
              ],
              const SizedBox(height: 20), // Spacing before the close button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(), // Close the dialog
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: text_helper(
                  data: "Close",
                  font: raleway,
                  color: Colors.black,
                  size: fontSize16,
                  bold: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileDetail(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kcPrimaryColor), // Icon color to match the theme
          const SizedBox(width: 10), // Spacing between icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text_helper(
                  data: title,
                  font: openSans,
                  color: kcDarkGreyColor,
                  size: fontSize14,
                  bold: true,
                ),
                text_helper(
                  data: description,
                  font: openSans,
                  color: kcDarkGreyColor,
                  size: fontSize14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget pdata(IconData data, String title, String des) {
    return Row(
      children: [
        Icon(data),
        horizontalSpaceTiny,
        text_helper(
          data: title,
          font: openSans,
          color: kcDarkGreyColor,
          size: fontSize12,
          bold: true,
        ),
        horizontalSpaceSmall,
        text_helper(
          data: des,
          font: openSans,
          color: kcDarkGreyColor,
          size: fontSize12,
        )
      ],
    );
  }

  Widget locfilter(BuildContext context, HomeViewModel viewModel,
      AsyncSnapshot snapshot, int index) {
    if (!viewModel.filter) {
      return listdata(context, snapshot.data[index] as Map, viewModel);
    } else {
      if (viewModel.loc.text.isEmpty && viewModel.currentloc.text.isEmpty) {
        return listdata(context, snapshot.data[index] as Map, viewModel);
      } else if (snapshot.data[index]['number']['adds']
          .toLowerCase()
          .contains(viewModel.currentloc.text.toLowerCase())) {
        return listdata(context, snapshot.data[index] as Map, viewModel);
      } else if (snapshot.data[index]['number']['adde']
          .toLowerCase()
          .contains(viewModel.loc.text.toLowerCase())) {
        return listdata(context, snapshot.data[index] as Map, viewModel);
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget listdata(BuildContext context, Map data, HomeViewModel viewModel) {
    DateTime dateFromString = DateTime.parse(data['number']['datetime']);
    DateTime currentDate = DateTime.now().subtract(const Duration(minutes: 60));
    int comparisonResult = dateFromString.compareTo(currentDate);
    return InkWell(
      onTap: () => viewModel.updateroute(data['number']),
      child: Container(
        width: screenWidth(context),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: getColorWithOpacity(kcPrimaryColor, 0.1),
        ),
        child: Column(
          children: [
            text_helper(
                data: data['user']['firstname'] +
                    " " +
                    data['user']['lastname'] +
                    " (" +
                    data['user']['cat'] +
                    ")",
                font: openSans,
                color: kcDarkGreyColor,
                size: fontSize14),
            rowdata(Icons.share_location_sharp, data['number']['adds'],
                bold: true),
            rowdata(Icons.edit_location_outlined, data['number']['adde'],
                bold: true, col: Colors.green),
            rowdata(Icons.timelapse, data['number']['datetime'].toString()),
            rowdata(Icons.compare_arrows, data['number']['dis'] + " km"),
            rowdata(Icons.currency_ruble, data['number']['price'] + " Rs",
                col: red),
            verticalSpaceTiny,
            AnimatedRatingStars(
              initialRating: int.parse(data['user']['itemrating']) /
                  int.parse(data['user']['itemuser']),
              minRating: 0.0,
              maxRating: 5.0,
              filledColor: Colors.amber,
              emptyColor: Colors.grey,
              filledIcon: Icons.star,
              halfFilledIcon: Icons.star_half,
              emptyIcon: Icons.star_border,
              onChanged: (double rating) {},
              displayRatingValue: true,
              interactiveTooltips: true,
              customFilledIcon: Icons.star,
              customHalfFilledIcon: Icons.star_half,
              customEmptyIcon: Icons.star_border,
              starSize: 20,
              animationDuration: const Duration(milliseconds: 300),
              animationCurve: Curves.easeInOut,
              readOnly: true,
            ),
            verticalSpaceTiny,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => viewModel.chat(data['number']['number']),
                  child: Container(
                    width: screenWidthCustom(context, 0.35),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kcDarkGreyColor),
                    child: text_helper(
                        data: "chat",
                        font: openSans,
                        bold: true,
                        color: white,
                        size: fontSize14),
                  ),
                ),
                data["number"]['status'] == "completed"
                    ? InkWell(
                        onTap: () => rating(context, data, viewModel),
                        child: Container(
                          width: screenWidthCustom(context, 0.35),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: red),
                          child: text_helper(
                              data: "Rate Now",
                              font: openSans,
                              bold: true,
                              color: white,
                              size: fontSize14),
                        ),
                      )
                    : data["number"]['status'] == "progress"
                        ? InkWell(
                            onTap: () => viewModel.aspect(data["number"]['_id'],
                                "completed", context, data),
                            child: Container(
                              width: screenWidthCustom(context, 0.35),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: kcDarkGreyColor),
                              child: text_helper(
                                  data: "Done Ride",
                                  font: openSans,
                                  bold: true,
                                  color: white,
                                  size: fontSize14),
                            ),
                          )
                        : (comparisonResult <= 0)
                            ? const SizedBox.shrink()
                            : InkWell(
                                onTap: () => viewModel.aspect(
                                    data["number"]['_id'],
                                    "progress",
                                    context,
                                    data),
                                child: Container(
                                  width: screenWidthCustom(context, 0.35),
                                  margin: const EdgeInsets.only(right: 10),
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: kcDarkGreyColor),
                                  child: text_helper(
                                      data: "Accept ride",
                                      font: openSans,
                                      bold: true,
                                      color: white,
                                      size: fontSize14),
                                ),
                              )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void rating(BuildContext context, Map data, HomeViewModel viewModel) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: text_helper(
                      data: "Add Review",
                      bold: true,
                      font: raleway,
                      color: kcDarkGreyColor,
                      size: fontSize18),
                ),
                text_helper(
                    data: "How was your experience",
                    font: raleway,
                    color: kcDarkGreyColor,
                    size: fontSize14),
                AnimatedRatingStars(
                  initialRating: 0.0,
                  minRating: 0.0,
                  maxRating: 5.0,
                  filledColor: Colors.amber,
                  emptyColor: Colors.grey,
                  filledIcon: Icons.star,
                  halfFilledIcon: Icons.star_half,
                  emptyIcon: Icons.star_border,
                  onChanged: (double rating) {
                    viewModel.rating = rating;
                    viewModel.notifyListeners();
                  },
                  displayRatingValue: true,
                  interactiveTooltips: true,
                  customFilledIcon: Icons.star,
                  customHalfFilledIcon: Icons.star_half,
                  customEmptyIcon: Icons.star_border,
                  starSize: 20,
                  animationDuration: const Duration(milliseconds: 300),
                  animationCurve: Curves.easeInOut,
                  readOnly: false,
                ),
                button_helper(
                  onpress: () => viewModel.addreview(context, data),
                  color: kcDarkGreyColor,
                  width: screenWidth(context) * 0.5, // Adjust width to 80% of screen width
                    child: text_helper(
                    data: "Add",
                    font: raleway,
                    color: Colors.white,
                    bold: true,
                    size: fontSize16, // Increase font size for better visibility
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget rowdata(IconData data, String title,
      {bool bold = false, Color col = kcDarkGreyColor}) {
    return Row(
      children: [
        Icon(data),
        horizontalSpaceTiny,
        Expanded(
            child: text_helper(
          data: title,
          textAlign: TextAlign.start,
          font: openSans,
          color: col,
          size: fontSize12,
          bold: bold,
        ))
      ],
    );
  }

  void showdialog(BuildContext context, HomeViewModel viewModel) {
    viewModel.selectedprice.clear();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            surfaceTintColor: white,
            child: Container(
              width: screenWidth(context),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(10),
              child: Material(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text_view_helper(
                      hint: "Custom price",
                      showicon: true,
                      textcolor: kcDarkGreyColor,
                      icon: const Icon(Icons.currency_ruble),
                      textInputType: TextInputType.number,
                      controller: viewModel.selectedprice),
                  verticalSpaceSmall,
                  InkWell(
                    onTap: () {
                      if (viewModel.selectedprice.text.isNotEmpty) {
                        if (viewModel.prices
                            .contains(viewModel.selectedprice.text)) {
                          Navigator.pop(context);
                        } else {
                          viewModel.prices.add(viewModel.selectedprice.text);
                          Navigator.pop(context);
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kcPrimaryColor),
                      child: const Icon(Icons.add),
                    ),
                  )
                ],
              )),
            ),
          );
        });
  }

  Widget selectionride(
      String val, HomeViewModel viewModel, BuildContext context) {
    return InkWell(
      onTap: () => viewModel.selectride(val),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: viewModel.ride == val
              ? getColorWithOpacity(kcPrimaryColor, 0.4)
              : Colors.transparent,
          border: Border.all(
              width: 2,
              color:
                  viewModel.ride == val ? kcDarkGreyColor : Colors.transparent),
        ),
        child: Image.asset(
          val == 'car' ? 'assets/car.png' : 'assets/bike.png',
          width: screenWidthCustom(context, 0.1),
          height: screenWidthCustom(context, 0.1),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(HomeViewModel viewModel) => viewModel.first();

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}
