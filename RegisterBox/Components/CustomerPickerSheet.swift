import SwiftUI

// MARK: - CustomerPickerSheet
/// Selector de cliente reutilizable. Usado en checkout en deuda.
struct CustomerPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let customers: [Customer]
    let onSelect: (Customer) -> Void

    @State private var searchText = ""

    private var filtered: [Customer] {
        if searchText.isEmpty { return customers }
        let query = searchText.lowercased()
        return customers.filter {
            $0.name.lowercased().contains(query) ||
            ($0.phone ?? "").lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: IconSize.xl))
                            .foregroundStyle(Color.rbGray)
                        Text("No hay clientes")
                            .font(.rbBody)
                            .foregroundStyle(Color.rbGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filtered) { customer in
                        Button {
                            onSelect(customer)
                            dismiss()
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: IconSize.lg))
                                    .foregroundStyle(Color.rbMedium)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(customer.name)
                                        .font(.rbBody)
                                        .foregroundStyle(Color.rbPrimary)
                                    if let phone = customer.phone {
                                        Text(phone)
                                            .font(.rbCaption)
                                            .foregroundStyle(Color.rbGray)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Seleccionar cliente")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar cliente")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.rbGray)
                }
            }
        }
    }
}
