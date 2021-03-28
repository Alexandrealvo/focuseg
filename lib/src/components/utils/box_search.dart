import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

Widget boxSearch(
  BuildContext context,
  TextEditingController searchController,
  onSearchTextChanged,
) {
  return Container(
    padding: EdgeInsets.all(10),
    color: Colors.red[900],
    child: TextField(
      onChanged: onSearchTextChanged == '' ? null : onSearchTextChanged,
      controller: searchController,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        /*labelText: "Pesquise",
        labelStyle: GoogleFonts.montserrat(
          fontSize: 18,
          color: Colors.white,
        ),*/
        prefixIcon: Icon(
          Feather.search,
          color: Colors.white,
          size: 23,
        ),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
  );
}
