//
//  ViewController.swift
//  CalenderSync
//
//  Created by Meet Budheliya on 06/09/23.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class ViewController: UIViewController, GIDSignInDelegate {
    
    //MARK: - Variables
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().clientID = "enter your key"// add plist file fro google console with auth enabled
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    //MARK: - Actions
    @IBAction func googleSignInBtnPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK: - Methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            addEventoToGoogleCalendar(summary: "summary-!", description: "description", startTime: "25/09/2023 09:00", endTime: "25/09/2023 10:00")
        }
    }
    
    //MARK: - Calender Event add
    // Create an event to the Google Calendar's user
    func addEventoToGoogleCalendar(summary : String, description :String, startTime : String, endTime : String) {
        let calendarEvent = GTLRCalendar_Event()
        
        calendarEvent.summary = "\(summary)"
        calendarEvent.descriptionProperty = "\(description)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let startDate = dateFormatter.date(from: startTime)
        let endDate = dateFormatter.date(from: endTime)
        
        guard let toBuildDateStart = startDate else {
            print("Error getting start date")
            return
        }
        guard let toBuildDateEnd = endDate else {
            print("Error getting end date")
            return
        }
        calendarEvent.start = buildDate(date: toBuildDateStart)
        calendarEvent.end = buildDate(date: toBuildDateEnd)
        
        let insertQuery = GTLRCalendarQuery_EventsInsert.query(withObject: calendarEvent, calendarId: "primary")
        
        service.executeQuery(insertQuery) { (ticket, object, error) in
            if error == nil {
                self.showAlert(title: "Success!", message: "Event inserted : \(ticket.service)")
            } else {
                self.showAlert(title: "error!", message: error?.localizedDescription ?? "!!!")
            }
        }
    }
    
    //MARK: - Helper methods
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func buildDate(date: Date) -> GTLRCalendar_EventDateTime {
        let datetime = GTLRDateTime(date: date)
        let dateObject = GTLRCalendar_EventDateTime()
        dateObject.dateTime = datetime
        return dateObject
    }
}

