import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

Widget boxSearch(
  BuildContext context,
  TextEditingController searchController,
  onSearchTextChanged,
) {
  return Container(
    padding: EdgeInsets.all(5),
    color: Colors.red[900],
    child: TextField(
      onChanged: onSearchTextChanged == '' ? null : onSearchTextChanged,
      controller: searchController,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: "Pesquise pelo nome",
        labelStyle: GoogleFonts.montserrat(
          fontSize: 18,
          color: Colors.black,
        ),
        prefixIcon: Icon(
          Feather.search,
          color: Colors.black,
          size: 23,
        ),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}
