import Foundation

struct Resume: Identifiable {
    let id = UUID()
    
    // Personal Information
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var linkedIn: String = ""
    
    // Education
    var education: [Education] = []
    
    // Experience
    var experience: [Experience] = []
    
    // Skills
    var skills: [String] = []
}

struct Education: Identifiable {
    let id = UUID()
    var schoolName: String = ""
    var degree: String = ""
    var startYear: String = ""
    var endYear: String = ""
}

struct Experience: Identifiable {
    let id = UUID()
    var companyName: String = ""
    var position: String = ""
    var startYear: String = ""
    var endYear: String = ""
    var description: String = ""
}
