//
//  LocationMapPickerSheet.swift
//  Lockty
//

import SwiftUI
import MapKit
import MapItemPicker

struct LocationMapPickerSheet: View {
    @Bindable var vm: CreateRuleViewModel

    var body: some View {
        NavigationStack {
            MapItemPicker(
                primaryMapItemAction: .init(
                    title: "Select",
                    imageName: "checkmark.circle.fill",
                    handler: { mapItem in
                        let streetLine = [mapItem.street, mapItem.housenumber]
                            .compactMap { $0 }
                            .joined(separator: " ")
                        let cityLine = [mapItem.postcode, mapItem.city]
                            .compactMap { $0 }
                            .joined(separator: " ")
                        let address = [
                            streetLine.isEmpty ? nil : streetLine,
                            cityLine.isEmpty ? nil : cityLine,
                            mapItem.state,
                            mapItem.country
                        ]
                        .compactMap { $0 }
                        .joined(separator: ", ")

                        vm.applySelectedLocation(
                            name: mapItem.name,
                            address: address,
                            coordinate: mapItem.location
                        )
                        return true
                    }
                )
            )
            .navigationTitle("Seleccionar ubicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        vm.showLocationPicker = false
                    }
                }
            }
        }
        .onAppear {
            vm.requestLocationIfNeeded()
        }
    }
}
