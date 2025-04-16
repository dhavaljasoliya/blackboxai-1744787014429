import SwiftUI
import PDFKit
import UIKit

struct ResumeFormView: View {
    @State private var resume = Resume()
    @State private var showShareSheet = false
    @State private var pdfURL: URL?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $resume.fullName)
                    TextField("Email", text: $resume.email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $resume.phone)
                        .keyboardType(.phonePad)
                    TextField("LinkedIn URL", text: $resume.linkedIn)
                        .keyboardType(.URL)
                }
                
                Section(header: Text("Education")) {
                    ForEach($resume.education) { $education in
                        VStack(alignment: .leading) {
                            TextField("School Name", text: $education.schoolName)
                            TextField("Degree", text: $education.degree)
                            HStack {
                                TextField("Start Year", text: $education.startYear)
                                    .keyboardType(.numberPad)
                                TextField("End Year", text: $education.endYear)
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    Button(action: {
                        resume.education.append(Education())
                    }) {
                        Label("Add Education", systemImage: "plus")
                    }
                }
                
                Section(header: Text("Experience")) {
                    ForEach($resume.experience) { $experience in
                        VStack(alignment: .leading) {
                            TextField("Company Name", text: $experience.companyName)
                            TextField("Position", text: $experience.position)
                            HStack {
                                TextField("Start Year", text: $experience.startYear)
                                    .keyboardType(.numberPad)
                                TextField("End Year", text: $experience.endYear)
                                    .keyboardType(.numberPad)
                            }
                            TextField("Description", text: $experience.description)
                        }
                    }
                    Button(action: {
                        resume.experience.append(Experience())
                    }) {
                        Label("Add Experience", systemImage: "plus")
                    }
                }
                
                Section(header: Text("Skills")) {
                    ForEach(resume.skills.indices, id: \.self) { index in
                        TextField("Skill", text: Binding(
                            get: { resume.skills[index] },
                            set: { resume.skills[index] = $0 }
                        ))
                    }
                    Button(action: {
                        resume.skills.append("")
                    }) {
                        Label("Add Skill", systemImage: "plus")
                    }
                }
                
                Section {
                    Button(action: {
                        if let url = generatePDF() {
                            pdfURL = url
                            showShareSheet = true
                        }
                    }) {
                        Text("Export & Share PDF")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Resume Builder")
            .sheet(isPresented: $showShareSheet) {
                if let pdfURL = pdfURL {
                    ShareSheet(activityItems: [pdfURL])
                }
            }
        }
    }
    
    func generatePDF() -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Smart Resume Builder",
            kCGPDFContextAuthor: resume.fullName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let subtitleAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)
            ]
            let bodyAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
            ]
            
            var yPosition: CGFloat = 20
            
            // Draw Full Name
            let fullName = resume.fullName as NSString
            fullName.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Draw Contact Info
            let contactInfo = "\(resume.email) | \(resume.phone) | \(resume.linkedIn)" as NSString
            contactInfo.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 30
            
            // Draw Education
            let educationTitle = "Education" as NSString
            educationTitle.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 25
            
            for edu in resume.education {
                let eduText = "\(edu.degree) - \(edu.schoolName) (\(edu.startYear) - \(edu.endYear))" as NSString
                eduText.draw(at: CGPoint(x: 30, y: yPosition), withAttributes: bodyAttributes)
                yPosition += 20
            }
            yPosition += 10
            
            // Draw Experience
            let experienceTitle = "Experience" as NSString
            experienceTitle.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 25
            
            for exp in resume.experience {
                let expText = "\(exp.position) - \(exp.companyName) (\(exp.startYear) - \(exp.endYear))" as NSString
                expText.draw(at: CGPoint(x: 30, y: yPosition), withAttributes: bodyAttributes)
                yPosition += 20
                let descText = exp.description as NSString
                descText.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: bodyAttributes)
                yPosition += 30
            }
            yPosition += 10
            
            // Draw Skills
            let skillsTitle = "Skills" as NSString
            skillsTitle.draw(at: CGPoint(x: 20, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 25
            
            let skillsText = resume.skills.joined(separator: ", ") as NSString
            skillsText.draw(at: CGPoint(x: 30, y: yPosition), withAttributes: bodyAttributes)
        }
        
        // Save PDF to temporary directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Resume.pdf")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Could not save PDF file: \(error)")
            return nil
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ResumeFormView_Previews: PreviewProvider {
    static var previews: some View {
        ResumeFormView()
    }
}
