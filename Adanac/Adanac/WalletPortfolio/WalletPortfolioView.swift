//
//  WalletPortfolioView.swift
//  Adanac
//
//  Created by Daniel Bell on 5/21/22.
//

import SwiftUI


struct WalletPortfolioView: View {
//    let addr: EthereumAddress
    @StateObject var viewModel = WalletViewModel()
    //            EthereumAddress("0x05E793cE0C6027323Ac150F6d45C2344d28B6019")
//    let ethAddress = "0x05E793cE0C6027323Ac150F6d45C2344d28B6019"
    var body: some View {
        VStack {

            VStack {

                HStack {
                    VStack(alignment: .leading) {

                        Text("My Wallet" + String(viewModel.addr?.address.last ?? "x") )
                            .foregroundColor(.secondaryOrange)
                            .font(.system(size: 28, weight: .semibold))
                        Text("Network")
                            .foregroundColor(.textForeground)
                            .font(.system(size: 15, weight: .regular))
                    }
                    Spacer()
                    HStack {
                        Circle()
                            .fill(EllipticalGradient(colors: [.green, .orange, .red], center: .leading, startRadiusFraction: 0.1, endRadiusFraction: 1))
                            .frame(width: 30, height: 30)
                            .importCardMinBorder()
                            .overlay(
                                Circle()
                                    .fill(Color.primaryOrange)
                                    .frame(width: 10, height: 10)
                                    .overlay(Circle().stroke(Color.black, lineWidth: 1 ))
                                    .offset(x: -15 + 20*((viewModel.gasPrice ?? 0.0000001)/225))
                                // gas guage
                                // normal <= 110
                                // busy > 110
                                // busy <=150
                                // congested >150
                            )
                        Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor( .primaryOrange)
                            .importCard()
                    }
                }
                .padding(.horizontal, 17)

                HStack {
                    Text("Balance")
                        .foregroundColor(.textForeground)
                        .opacity(0.6)
                        .font(.system(size: 16, weight: .regular))
                    Text("Ξ " + viewModel.balance)
                        .foregroundColor(.secondaryOrange)
                        .font(.system(size: 26, weight: .regular))
                    Spacer()
                }
                .padding(.top, 21)
                .padding(.horizontal, 17)

            }// make like credit card/ swipe to change address
// ========================================================================
            Spacer()
            VStack {

                HStack {
                    Text("Markets")
                    Spacer()
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(viewModel.nftHoldings) { nftListing in
                            Text(nftListing.name ?? "--")
                            // show the groupings not the individual ones
                        }
                        .background(Color.orange)
                    }
                }
            }
            .importCard()
// ========================================================================
            Spacer()
            VStack {

                HStack {
                    Text("NFT")
                    Spacer()
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(viewModel.nftHoldings) { nftListing in
                            Text(nftListing.name ?? "--")
                            // show the groupings not the individual ones
                        }
                        .background(Color.orange)
                    }
                }
            }
            .importCard()
// ========================================================================
            VStack {
                HStack {
                    Text("Assets")
                    Spacer()
                    Text("Tokens: \(viewModel.erc20Holdings.count)")
                    Text("->")
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 2.0) {
                        ForEach(viewModel.erc20Holdings) { ercListing in
                            VStack {
                                HStack(alignment: .top) {
                                    Text(ercListing.symbol ?? "--")
                                        .font(.system(size: 17, weight: .bold))
                                    Spacer()
                                    if let imageURLString = ercListing.logo {
                                        AsyncImage(url: URL(string: imageURLString)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 40, height: 40)
                                    }
                                }

                                Text("\(ercListing.displayBalance ?? 0, specifier: "%.2f")")
                                    .font(.system(size: 17, weight: .regular))
                            }
                            .padding(16)
                        }
                        .background(Color.background.opacity(0.75))
                    }
                }
            }
            .importCard()
// ========================================================================
            // Address Logs
// ========================================================================
        }
        .background(Color.background)
        .onAppear {
            Task {
                await viewModel.setAddress("0xca436e14855323927d6e6264470ded36455fc8bd")
//      API Call does not succeed
//                  0x57757e3d981446d585af0d9ae4d7df6d64647806
//                  0xa9D60735AB0901F84F5D04b465FA2F1a6d0Aa7Ee
//                  0x853B811892B8107860E8b71e670a83C462B4A507
//                  0x84D34f4f83a87596Cd3FB6887cFf8F17Bf5A7B83
//                0x1Db3439a222C519ab44bb1144fC28167b4Fa6EE6
//                  0x179456bf16752FE5Eb8789148E5C98Eb39D87Fe5

//      Integrate into app
//                  0xca436e14855323927d6e6264470ded36455fc8bd
//                0x220866b1a2219f40e72f5c628b65d54268ca3a9d
//                0xc5ed2333f8a2C351fCA35E5EBAdb2A82F5d254C3
//                0x068B65394EBB0e19DFF45880729C77fAAF3b5195
//                0xf74344E4C2Dfdc9aB5DDF6E95379c7119e2bBc56
//                0x853B811892B8107860E8b71e670a83C462B4A507

//                0x1BC80b413562Bc3362f7e8d7431255d5D18441a7

                // NFT CARD
                // How many projects
                // total count
            }
        }
    }
}
