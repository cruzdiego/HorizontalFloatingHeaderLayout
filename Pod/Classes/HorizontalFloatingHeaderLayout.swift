//
//  HorizontalFloatingHeaderLayout.swift
//  Pods
//
//  Created by Diego Alberto Cruz Castillo on 12/30/15.
//  Updated by Harshit Daftary on 2/28/17.
//

import UIKit

@objc public protocol HorizontalFloatingHeaderLayoutDelegate{
    //Item size
    func collectionView(_ collectionView: UICollectionView,horizontalFloatingHeaderItemSizeForItemAtIndexPath indexPath:IndexPath) -> CGSize
    
    //Header size
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSizeForSectionAtIndex section: Int) -> CGSize
    
    //Section Inset
    @objc optional func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetForSectionAtIndex section: Int) -> UIEdgeInsets
    
    //Item Spacing
    @objc optional func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAtIndex section: Int) -> CGFloat
    
    //Line Spacing
    @objc optional func collectionView(_ collectionView: UICollectionView,horizontalFloatingHeaderColumnSpacingForSectionAtIndex section: Int) -> CGFloat
}

open class HorizontalFloatingHeaderLayout: UICollectionViewLayout {
    //MARK: - Properties
    //MARK: Headers properties
    //Variables
    var sectionHeadersAttributes: [IndexPath:UICollectionViewLayoutAttributes]{
        get{
            return getSectionHeadersAttributes()
        }
    }
    //MARK: Items properties
    //Variables
    var itemsAttributes = [IndexPath:UICollectionViewLayoutAttributes]()
    //PrepareItemsAtributes only
    var currentMinX:CGFloat = 0
    var currentMinY:CGFloat = 0
    var currentMaxX:CGFloat = 0
    
    //MARK: - PrepareForLayout methods
    open override func prepare() {
        prepareItemsAttributes()
    }
    
    //Items
    fileprivate func prepareItemsAttributes(){
        func resetAttributes(){
            itemsAttributes.removeAll()
            currentMinX = 0
            currentMaxX = 0
            currentMinY = 0
        }
        
        func configureVariables(forSection section:Int){
            let sectionInset = inset(ForSection: section)
            let lastSectionInset = inset(ForSection: section - 1)
            currentMinX = (currentMaxX + sectionInset.left + lastSectionInset.right)
            currentMinY = sectionInset.top + headerSize(forSection: section).height
            currentMaxX = 0.0
        }
        
        func itemAttribute(atIndexPath indexPath:IndexPath)->UICollectionViewLayoutAttributes{
            //Applying corrected layout
            func newLineOrigin(size:CGSize)->CGPoint{
                var origin = CGPoint.zero
                origin.x = currentMaxX + columnSpacing(forSection: indexPath.section)
                origin.y = inset(ForSection: indexPath.section).top + headerSize(forSection: indexPath.section).height
                return origin
            }
            
            func sameLineOrigin(size:CGSize)->CGPoint{
                var origin = CGPoint.zero
                origin.x = currentMinX
                origin.y = currentMinY
                return origin
            }
            
            func updateVariables(itemFrame frame:CGRect){
                currentMaxX = max(currentMaxX,frame.maxX)
                currentMinX = frame.minX
                currentMinY = frame.maxY + itemSpacing(forSection: indexPath.section)
            }
            
            //
            let size = itemSize(ForIndexPath: indexPath)
            let newMaxY = currentMinY + size.height
            let origin:CGPoint
            if newMaxY >  availableHeight(atSection: indexPath.section){
                origin = newLineOrigin(size: size)
            }else{
                origin = sameLineOrigin(size: size)
            }
            let frame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = frame
            updateVariables(itemFrame: frame)
            return attribute
        }
        
        //
        resetAttributes()
        let sectionCount = collectionView!.numberOfSections
        for section in 0 ..< sectionCount {
            configureVariables(forSection: section)
            let itemCount = collectionView!.numberOfItems(inSection: section)
            for index in 0 ..< itemCount {
                let indexPath = IndexPath(row: index, section: section)
                let attribute = itemAttribute(atIndexPath: indexPath)
                itemsAttributes[indexPath] = attribute
            }
        }
    }
    
    //MARK: - LayoutAttributesForElementsInRect methods
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        func attributes(_ attributes:[IndexPath:UICollectionViewLayoutAttributes],containedIn rect:CGRect) -> [UICollectionViewLayoutAttributes]{
            var finalAttributes = [UICollectionViewLayoutAttributes]()
            for (_,attribute) in attributes{
                if rect.intersects(attribute.frame){
                    finalAttributes.append(attribute)
                }
            }
            
            return finalAttributes
        }
        
        //
        let itemsA = attributes(itemsAttributes, containedIn: rect)
        let headersA = Array(sectionHeadersAttributes.values)
        return itemsA + headersA
    }
    
    //MARK: - ContentSize methods
    override open var collectionViewContentSize : CGSize {
        func lastItemMaxX()->CGFloat{
            let lastSection = collectionView!.numberOfSections - 1
            let lastIndexInSection = collectionView!.numberOfItems(inSection: lastSection) - 1
            if let lastItemAttributes = layoutAttributesForItem(at: IndexPath(row: lastIndexInSection, section: lastSection)){
                return lastItemAttributes.frame.maxX
            }else{
                return 0
            }
        }
        //
        let lastSection = collectionView!.numberOfSections - 1
        let contentWidth = lastItemMaxX() + inset(ForSection: lastSection).right
        let contentHeight = collectionView!.bounds.height - collectionView!.contentInset.top - collectionView!.contentInset.bottom
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    //MARK: - LayoutAttributes methods
    //MARK: For ItemAtIndexPath
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let fromIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        return itemsAttributes[fromIndexPath]
    }
    //MARK: For SupplementaryViewOfKind
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader{
            let fromIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            return sectionHeadersAttributes[fromIndexPath]
        }else{
            return nil
        }
    }
    
    //MARK: - Utility methods
    //MARK: SectionHeaders Attributes methods
    fileprivate func getSectionHeadersAttributes()->[IndexPath:UICollectionViewLayoutAttributes]{
        func attributeForSectionHeader(atIndexPath indexPath:IndexPath) -> UICollectionViewLayoutAttributes{
            func size()->CGSize{
                return headerSize(forSection: indexPath.section)
            }
            //
            func position()->CGPoint{
                if let itemsCount = collectionView?.numberOfItems(inSection: indexPath.section),
                    let firstItemAttributes = layoutAttributesForItem(at: indexPath),
                    let lastItemAttributes = layoutAttributesForItem(at: IndexPath(row: itemsCount-1, section: indexPath.section)){
                        let edgeX = collectionView!.contentOffset.x + collectionView!.contentInset.left
                        let xByLeftBoundary = max(edgeX,firstItemAttributes.frame.minX)
                        //
                        let width = size().width
                        let xByRightBoundary = lastItemAttributes.frame.maxX - width
                        let x = min(xByLeftBoundary,xByRightBoundary)
                        return CGPoint(x: x, y: 0)
                }else{
                    return CGPoint(x: inset(ForSection: indexPath.section).left, y: 0)
                }
            }
            //
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
            let myPosition = position()
            let mySize = size()
            let frame = CGRect(x: myPosition.x, y: myPosition.y, width: mySize.width, height: mySize.height)
            attribute.frame = frame
            
            return attribute
        }
        //
        let sectionCount = collectionView!.numberOfSections
        var attributes = [IndexPath:UICollectionViewLayoutAttributes]()
        for section in 0 ..< sectionCount {
            let indexPath = IndexPath(row: 0, section: section)
            attributes[indexPath] = attributeForSectionHeader(atIndexPath: indexPath)
        }
        return attributes
    }
    
    //MARK: - Invalidating layout methods
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        func isSizeChanged()->Bool{
            let oldBounds = collectionView!.bounds
            return oldBounds.width != newBounds.width || oldBounds.height != newBounds.height
        }
        
        func headersIndexPaths()->[IndexPath]{
            return Array(sectionHeadersAttributes.keys)
        }
        
        //
        let context = super.invalidationContext(forBoundsChange: newBounds)
        if !isSizeChanged(){
            context.invalidateSupplementaryElements(ofKind: UICollectionElementKindSectionHeader, at: headersIndexPaths())
        }
        return context
    }
    
    //MARK: - Utility methods
    fileprivate func itemSize(ForIndexPath indexPath:IndexPath) -> CGSize{
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate else {return CGSize.zero}
        return delegate.collectionView(collectionView!, horizontalFloatingHeaderItemSizeForItemAtIndexPath: indexPath)
    }
    
    fileprivate func headerSize(forSection section:Int) -> CGSize{
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate, section >= 0 else {return CGSize.zero}
        return delegate.collectionView(collectionView!, horizontalFloatingHeaderSizeForSectionAtIndex: section)
    }
    
    fileprivate func inset(ForSection section:Int) -> UIEdgeInsets{
        let defaultValue = UIEdgeInsets.zero
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate, section >= 0 else {return defaultValue}
        
        return delegate.collectionView?(collectionView!, horizontalFloatingHeaderSectionInsetForSectionAtIndex: section) ?? defaultValue
    }
    
    fileprivate func columnSpacing(forSection section:Int) -> CGFloat{
        let defaultValue:CGFloat = 0.0
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate, section >= 0 else {return defaultValue}
        
        return delegate.collectionView?(collectionView!, horizontalFloatingHeaderColumnSpacingForSectionAtIndex: section) ?? defaultValue
    }
    
    fileprivate func itemSpacing(forSection section:Int) -> CGFloat{
        let defaultValue:CGFloat = 0.0
        guard let delegate = collectionView?.delegate as? HorizontalFloatingHeaderLayoutDelegate, section >= 0 else {return defaultValue}
        return delegate.collectionView?(collectionView!, horizontalFloatingHeaderItemSpacingForSectionAtIndex: section) ?? defaultValue
    }
    
    fileprivate func availableHeight(atSection section:Int)->CGFloat{
        func totalInset()->CGFloat{
            let sectionInset = inset(ForSection: section)
            let contentInset = collectionView!.contentInset
            return sectionInset.top + sectionInset.bottom + contentInset.top + contentInset.bottom
        }
        
        //
        guard section >= 0 else {return 0.0}
        return collectionView!.bounds.height - totalInset()
    }
}
