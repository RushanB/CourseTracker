//
//  CourseStore+UICollectionViewDataSource.swift
//  CourseTracker
//
//  Created by atfelix on 2017-06-21.
//  Copyright © 2017 Adam Felix. All rights reserved.
//

import UIKit

extension CourseStore: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sectionsToCollapse.index(of: section) != nil {
            return numberOfRowsInEachGroup(section)
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseIcon", for: indexPath) as! CourseCollectionViewCell
        let course = courseFor(indexPath: indexPath)
        cell.courseLabel.text = course?.code
        cell.courseLabel.textColor = .white
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfGroups()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? DepartmentCollectionReusableView else {
            return UICollectionReusableView()
        }

        headerView.button.tag = indexPath.section
        headerView.button.addTarget(self, action: #selector(headerButtonTapped(with:)), for: .touchUpInside)

        headerView.departmentLabel.text = getGroupLabelAtIndex(indexPath.section)

        headerView.backgroundColor = .black

        return headerView
    }

    func headerButtonTapped(with button: UIButton){

        defer { delegate.reloadData() }

        guard let index = sectionsToCollapse.index(of: button.tag) else {
            sectionsToCollapse.append(button.tag)
            return
        }
        sectionsToCollapse.remove(at: index)
    }
}